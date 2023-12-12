//
//  CommonRateAppService.swift
//  Tangem
//
//  Created by Andrey Fedorov on 07.12.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

final class CommonRateAppService {
    weak var delegate: RateAppServiceDelegate?

    @AppStorageCompat(StorageKeys.systemReviewPromptRequestDates)
    private var systemReviewPromptRequestDates: [Date] = []

    @AppStorageCompat(StorageKeys.lastRequestedReviewDate)
    private var lastRequestedReviewDate: Date = .distantPast

    @AppStorageCompat(StorageKeys.lastRequestedReviewLaunchCount)
    private var lastRequestedReviewLaunchCount: Int = 0

    @AppStorageCompat(StorageKeys.userDismissedLastRequestedReview)
    private var userDismissedLastRequestedReview: Bool = false

    private var positiveBalanceAppearanceDate: Date? {
        get { AppSettings.shared.positiveBalanceAppearanceDate }
        set { AppSettings.shared.positiveBalanceAppearanceDate = newValue }
    }

    private var currentLaunchCount: Int { AppSettings.shared.numberOfLaunches }

    private var requiredNumberOfLaunches: Int {
        return userDismissedLastRequestedReview
            ? Constants.dismissedReviewRequestNumberOfLaunchesInterval
            : Constants.normalReviewRequestNumberOfLaunchesInterval
    }

    private lazy var calendar = Calendar(identifier: .gregorian)

    init() {
        trimStorageIfNeeded()
    }

    private func updatePositiveBalanceAppearanceDateIfNeeded(with request: RateAppRequest) {
        guard
            positiveBalanceAppearanceDate == nil,
            request.pageInfos.contains(where: \.isBalanceNonEmpty)
        else {
            return
        }

        positiveBalanceAppearanceDate = Date()
    }

    private func handleRateAppResult(_ result: RateAppResult) {
        switch result {
        case .positiveResponse:
            systemReviewPromptRequestDates.append(Date())
            delegate?.requestAppStoreReviewForRateAppService(self)
        case .negativeResponse:
            delegate?.rateAppService(self, didRequestOpenMailWithEmailType: .negativeRateAppFeedback)
        case .dismissed:
            userDismissedLastRequestedReview = true
        }
    }

    private func makeSystemReviewPromptReferenceDate() -> Date? {
        return calendar.date(byAdding: .year, value: -Constants.systemReviewPromptTimeWindowSize, to: Date())
    }

    private func trimStorageIfNeeded() {
        let storageMaxSize = Constants.systemReviewPromptRequestDatesMaxSize
        if systemReviewPromptRequestDates.count > storageMaxSize {
            systemReviewPromptRequestDates = systemReviewPromptRequestDates.suffix(storageMaxSize)
        }
    }
}

// MARK: - RateAppService protocol conformance

extension CommonRateAppService: RateAppService {
    func requestRateAppIfAvailable(with request: RateAppRequest) {
        updatePositiveBalanceAppearanceDateIfNeeded(with: request)

        guard let selectedPage = request.pageInfos.first(where: \.isSelected) else { return }

        if selectedPage.isLocked {
            return
        }

        guard selectedPage.isBalanceLoaded else {
            return
        }

        if selectedPage.displayedNotifications.contains(where: { Constants.forbiddenSeverityLevels.contains($0.severity) }) {
            return
        }

        guard positiveBalanceAppearanceDate != nil else {
            return
        }

        guard lastRequestedReviewDate.timeIntervalSinceNow < -Constants.reviewRequestTimeInterval else {
            return
        }

        guard currentLaunchCount - lastRequestedReviewLaunchCount >= requiredNumberOfLaunches else {
            return
        }

        guard let referenceDate = makeSystemReviewPromptReferenceDate() else {
            return
        }

        let systemReviewPromptRequestDatesWithinLastYear = systemReviewPromptRequestDates.filter { $0 >= referenceDate }

        guard systemReviewPromptRequestDatesWithinLastYear.count < Constants.systemReviewPromptMaxCountPerYear else {
            return
        }

        lastRequestedReviewDate = Date()
        lastRequestedReviewLaunchCount = currentLaunchCount
        userDismissedLastRequestedReview = false

        delegate?.rateAppService(
            self,
            didRequestRateAppWithCompletionHandler: weakify(self, forFunction: CommonRateAppService.handleRateAppResult(_:))
        )
    }
}

// MARK: - Auxiliary types

private extension CommonRateAppService {
    enum StorageKeys: String, RawRepresentable {
        case systemReviewPromptRequestDates = "system_review_prompt_request_dates"
        case lastRequestedReviewDate = "last_requested_review_date"
        case lastRequestedReviewLaunchCount = "last_requested_review_launch_count"
        case userDismissedLastRequestedReview = "user_dismissed_last_requested_review"
    }
}

// MARK: - Constants

private extension CommonRateAppService {
    enum Constants {
        // MARK: - Constants that control the behavior of the rate app sheet itself

        /// The user interacted with the review prompt.
        static let normalReviewRequestNumberOfLaunchesInterval = 3
        /// The user dismissed the review prompt w/o interaction.
        static let dismissedReviewRequestNumberOfLaunchesInterval = 20
        /// Three days.
        static let reviewRequestTimeInterval: TimeInterval = 3600 * 24 * 3

        static let forbiddenSeverityLevels: Set<NotificationView.Severity> = [
            .warning,
            .critical,
        ]

        // MARK: - Constants that control the behavior of the system rate app prompt (`SKStoreReviewController`)

        /// See https://developer.apple.com/documentation/storekit/requesting_app_store_reviews for details.
        static let systemReviewPromptMaxCountPerYear = 3
        /// Years, see https://developer.apple.com/documentation/storekit/requesting_app_store_reviews for details.
        static let systemReviewPromptTimeWindowSize = 1
        /// For storage trimming.
        static let systemReviewPromptRequestDatesMaxSize = 5
    }
}
