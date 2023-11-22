//
//  SendViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI
import BlockchainSdk

final class SendViewModel: ObservableObject {
    // MARK: - ViewState

    @Published var step: SendStep
    @Published var currentStepInvalid: Bool = false
    @Published var alert: AlertBinder?

    var title: String {
        step.name
    }

    var showNavigationButtons: Bool {
        step.hasNavigationButtons
    }

    var showBackButton: Bool {
        previousStep != nil
    }

    var showNextButton: Bool {
        nextStep != nil
    }

    let sendAmountViewModel: SendAmountViewModel
    let sendDestinationViewModel: SendDestinationViewModel
    let sendFeeViewModel: SendFeeViewModel
    let sendSummaryViewModel: SendSummaryViewModel

    // MARK: - Dependencies

    private var nextStep: SendStep? {
        guard
            let currentStepIndex = steps.firstIndex(of: step),
            (currentStepIndex + 1) < steps.count
        else {
            return nil
        }

        return steps[currentStepIndex + 1]
    }

    private var previousStep: SendStep? {
        guard
            let currentStepIndex = steps.firstIndex(of: step),
            (currentStepIndex - 1) >= 0
        else {
            return nil
        }

        return steps[currentStepIndex - 1]
    }

    private let sendModel: SendModel
    private let sendType: SendType
    private let steps: [SendStep]
    private let walletModel: WalletModel
    private let emailData: [EmailCollectedData]
    private let emailConfig: EmailConfig

    private unowned let coordinator: SendRoutable

    private var bag: Set<AnyCancellable> = []

    private var currentStepValid: AnyPublisher<Bool, Never> {
        $step
            .flatMap { [weak self] step -> AnyPublisher<Bool, Never> in
                guard let self else {
                    return .just(output: true)
                }

                switch step {
                case .amount:
                    return sendModel.amountValid
                case .destination:
                    return sendModel.destinationValid
                case .fee:
                    return sendModel.feeValid
                case .summary:
                    return .just(output: true)
                }
            }
            .eraseToAnyPublisher()
    }

    init(walletModel: WalletModel, transactionSigner: TransactionSigner, sendType: SendType, emailData: [EmailCollectedData], emailConfig: EmailConfig, coordinator: SendRoutable) {
        self.coordinator = coordinator
        self.sendType = sendType
        self.walletModel = walletModel
        self.emailData = emailData
        self.emailConfig = emailConfig
        sendModel = SendModel(walletModel: walletModel, transactionSigner: transactionSigner, sendType: sendType)

        let steps = sendType.steps
        guard let firstStep = steps.first else {
            fatalError("No steps provided for the send type")
        }
        self.steps = steps
        step = firstStep

        sendAmountViewModel = SendAmountViewModel(input: sendModel)
        sendDestinationViewModel = SendDestinationViewModel(input: sendModel)
        sendFeeViewModel = SendFeeViewModel(input: sendModel)
        sendSummaryViewModel = SendSummaryViewModel(input: sendModel)

        sendAmountViewModel.delegate = self
        sendSummaryViewModel.router = self

        bind()
    }

    func next() {
        guard let nextStep else {
            assertionFailure("Invalid step logic -- next")
            return
        }

        step = nextStep
    }

    func back() {
        guard let previousStep else {
            assertionFailure("Invalid step logic -- back")
            return
        }

        step = previousStep
    }

    private func bind() {
        currentStepValid
            .map {
                !$0
            }
            .assign(to: \.currentStepInvalid, on: self, ownership: .weak)
            .store(in: &bag)

        sendModel
            .isSending
            .removeDuplicates()
            .sink { [weak self] isSending in
                self?.setLoadingViewVisibile(isSending)
            }
            .store(in: &bag)

        sendModel
            .sendError
            .compactMap { $0 }
            .sink { [weak self] sendError in
                guard let self else { return }

                alert = SendError(sendError, openMailAction: openMail).alertBinder
            }
            .store(in: &bag)

        sendModel
            .transactionFinished
            .sink { [weak self] transactionFinished in
                guard let self, transactionFinished else { return }

                if walletModel.isDemo {
                    alert = AlertBuilder.makeSuccessAlert(message: Localization.alertDemoFeatureDisabled) {
                        self.coordinator.dismiss()
                    }
                }
            }
            .store(in: &bag)
    }

    private func setLoadingViewVisibile(_ visible: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if visible {
            appDelegate.addLoadingView()
        } else {
            appDelegate.removeLoadingView()
        }
    }

    private func openMail(with error: Error) {
        guard let transaction = sendModel.currentTransaction() else { return }

        let emailDataCollector = SendScreenDataCollector(
            userWalletEmailData: emailData,
            walletModel: walletModel,
            fee: transaction.fee.amount,
            destination: transaction.destinationAddress,
            amount: transaction.amount,
            isFeeIncluded: sendModel.isFeeIncluded,
            lastError: error
        )
        coordinator.openMail(with: emailDataCollector, recipient: emailConfig.recipient)
    }
}

extension SendViewModel: SendSummaryRoutable {
    func openStep(_ step: SendStep) {
        self.step = step
    }

    func send() {
        sendModel.send()
    }
}

extension SendViewModel: SendAmountViewModelDelegate {
    func didTapMaxAmount() {
        sendModel.useMaxAmount()
    }
}
