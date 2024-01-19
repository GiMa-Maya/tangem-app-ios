//
//  WalletModel+.swift
//  Tangem
//
//  Created by Andrew Son on 04/09/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

extension WalletModel {
    enum SendBlockedReason {
        struct NotEnoughFeeConfiguration: Hashable {
            let transactionAmountTypeName: String
            let feeAmountTypeName: String
            let feeAmountTypeCurrencySymbol: String
            let feeAmountTypeIconName: String
            let networkName: String
        }

        case cantSignLongTransactions
        case hasPendingCoinTx(symbol: String)
        case notEnoughFeeForTransaction(configuration: NotEnoughFeeConfiguration)

        var description: String {
            switch self {
            case .cantSignLongTransactions:
                return Localization.warningLongTransactionMessage
            case .hasPendingCoinTx(let symbol):
                return Localization.warningSendBlockedPendingTransactionsMessage(symbol)
            case .notEnoughFeeForTransaction(let configuration):
                return Localization.warningSendBlockedFundsForFeeMessage(
                    configuration.transactionAmountTypeName,
                    configuration.networkName,
                    configuration.transactionAmountTypeName,
                    configuration.feeAmountTypeName,
                    configuration.feeAmountTypeCurrencySymbol
                )
            }
        }
    }
}

extension WalletModel: Equatable {
    static func == (lhs: WalletModel, rhs: WalletModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension WalletModel {
    struct Id: Hashable, Identifiable, Equatable {
        var id: Int { hashValue }

        let blockchainNetwork: BlockchainNetwork
        let amountType: Amount.AmountType
    }
}

extension WalletModel: Identifiable {
    var id: Int {
        Id(blockchainNetwork: blockchainNetwork, amountType: amountType).id
    }
}

extension WalletModel: Hashable {
    func hash(into hasher: inout Hasher) {
        let id = Id(blockchainNetwork: blockchainNetwork, amountType: amountType)
        hasher.combine(id)
    }
}

extension WalletModel {
    enum TransactionHistoryState: CustomStringConvertible {
        case notSupported
        case notLoaded
        case loading
        case loaded(items: [TransactionRecord])
        case error(Error)

        var description: String {
            switch self {
            case .notSupported:
                return "TransactionHistoryState.notSupported"
            case .notLoaded:
                return "TransactionHistoryState.notLoaded"
            case .loading:
                return "TransactionHistoryState.loading"
            case .loaded(let items):
                return "TransactionHistoryState.loaded with items: \(items.count)"
            case .error(let error):
                return "TransactionHistoryState.error with \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - CustomStringConvertible protocol conformance

extension WalletModel: CustomStringConvertible {
    var description: String {
        objectDescription(
            self,
            userInfo: [
                "name": name,
                "isMainToken": isMainToken,
                "tokenItem": "\(tokenItem.name) (\(tokenItem.networkName))",
            ]
        )
    }
}
