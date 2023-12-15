//
//  ExpressProviderFormatter.swift
//  Tangem
//
//  Created by Sergey Balashov on 20.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import TangemSwapping

struct ExpressProviderFormatter {
    let balanceFormatter: BalanceFormatter

    func mapToRateSubtitle(
        state: ExpressProviderManagerState,
        senderCurrencyCode: String?,
        destinationCurrencyCode: String?,
        option: RateSubtitleFormattingOption
    ) -> ProviderRowViewModel.Subtitle {
        switch state {
        case .error(_, .none):
            return .text(AppConstants.minusSign)
        case .restriction(.tooSmallAmount(let minAmount), .none):
            guard let senderCurrencyCode else {
                return .text(CommonError.noData.localizedDescription)
            }

            let formatted = balanceFormatter.formatCryptoBalance(minAmount, currencyCode: senderCurrencyCode)
            return .text(Localization.expressProviderMinAmount(formatted))
        default:
            guard let quote = state.quote else {
                return .text(AppConstants.minusSign)
            }

            return mapToRateSubtitle(
                fromAmount: quote.fromAmount,
                toAmount: quote.expectAmount,
                senderCurrencyCode: senderCurrencyCode,
                destinationCurrencyCode: destinationCurrencyCode,
                option: option
            )
        }
    }

    func mapToRateSubtitle(
        fromAmount: Decimal,
        toAmount: Decimal,
        senderCurrencyCode: String?,
        destinationCurrencyCode: String?,
        option: RateSubtitleFormattingOption
    ) -> ProviderRowViewModel.Subtitle {
        switch option {
        case .exchangeRate:
            guard let senderCurrencyCode, let destinationCurrencyCode else {
                return .text(CommonError.noData.localizedDescription)
            }

            let rate = toAmount / fromAmount
            let formattedSourceAmount = balanceFormatter.formatCryptoBalance(1, currencyCode: senderCurrencyCode)
            let formattedDestinationAmount = balanceFormatter.formatCryptoBalance(rate, currencyCode: destinationCurrencyCode)

            return .text("\(formattedSourceAmount) ≈ \(formattedDestinationAmount)")
        case .exchangeReceivedAmount:
            guard let destinationCurrencyCode else {
                return .text(CommonError.noData.localizedDescription)
            }

            let formatted = balanceFormatter.formatCryptoBalance(toAmount, currencyCode: destinationCurrencyCode)
            return .text(formatted)
        }
    }

    func mapToProvider(provider: ExpressProvider) -> ProviderRowViewModel.Provider {
        ProviderRowViewModel.Provider(
            id: provider.id,
            iconURL: provider.imageURL,
            name: provider.name,
            type: provider.type.rawValue.uppercased()
        )
    }

    func mapToLegalText(provider: ExpressProvider) -> NSAttributedString? {
        let tos = Localization.expressTermsOfUse
        let policy = Localization.expressPrivacyPolicy

        if let termsOfUse = provider.termsOfUse, let privacyPolicy = provider.privacyPolicy {
            let text = Localization.expressLegalTwoPlaceholders(tos, policy)
            let attributedString = NSMutableAttributedString(string: text)

            if let range = text.range(of: tos) {
                attributedString.addAttributes([.link: termsOfUse], range: NSRange(range, in: text))
            }

            if let range = text.range(of: policy) {
                attributedString.addAttributes([.link: privacyPolicy], range: NSRange(range, in: text))
            }

            return attributedString
        }

        if let termsOfUse = provider.termsOfUse {
            let text = Localization.expressLegalOnePlaceholder(tos)
            let attributedString = NSMutableAttributedString(string: text)
            if let range = text.range(of: tos) {
                attributedString.addAttributes([.link: termsOfUse], range: NSRange(range, in: text))
            }

            return attributedString
        }

        if let privacyPolicy = provider.privacyPolicy {
            let text = Localization.expressLegalOnePlaceholder(policy)
            let attributedString = NSMutableAttributedString(string: text)
            if let range = text.range(of: policy) {
                attributedString.addAttributes([.link: privacyPolicy], range: NSRange(range, in: text))
            }

            return attributedString
        }

        return nil
    }
}

extension ExpressProviderFormatter {
    enum RateSubtitleFormattingOption {
        // How many destination's tokens user will get for the 1 token of source
        case exchangeRate

        // How many destination's tokens user will get at the end of swap
        case exchangeReceivedAmount
    }
}
