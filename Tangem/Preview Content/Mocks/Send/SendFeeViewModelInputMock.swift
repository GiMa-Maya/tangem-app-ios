//
//  SendFeeViewModelInputMock.swift
//  Tangem
//
//  Created by Andrey Chukavin on 01.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine
import BigInt
import BlockchainSdk

class SendFeeViewModelInputMock: SendFeeViewModelInput {
    var customGasPricePublisher: AnyPublisher<BigUInt?, Never> {
        .just(output: nil)
    }

    var selectedFeeOption: FeeOption {
        .market
    }

    var feeOptions: [FeeOption] {
        [.slow, .market, .fast, .custom]
    }

    var feeValues: AnyPublisher<[FeeOption: LoadingValue<Fee>], Never> {
        .just(output: [
            .slow: .loaded(.init(.init(with: .ethereum(testnet: false), type: .coin, value: 1))),
            .market: .loaded(.init(.init(with: .ethereum(testnet: false), type: .coin, value: 2))),
            .fast: .loaded(.init(.init(with: .ethereum(testnet: false), type: .coin, value: 3))),
        ])
    }

    var tokenItem: TokenItem { .blockchain(.ethereum(testnet: false)) }

    func didSelectFeeOption(_ feeOption: FeeOption) {}

    func didChangeCustomFeeGasPrice(_ value: BigUInt?) {}
}
