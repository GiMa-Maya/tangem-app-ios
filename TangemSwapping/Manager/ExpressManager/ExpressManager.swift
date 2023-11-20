//
//  ExpressManager.swift
//  TangemSwapping
//
//  Created by Sergey Balashov on 08.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

public protocol ExpressManager {
    func getPair() async -> ExpressManagerSwappingPair?
    func updatePair(pair: ExpressManagerSwappingPair) async throws -> ExpressManagerState

    func getAmount() async -> Decimal?
    func updateAmount(amount: Decimal?) async throws -> ExpressManagerState

    func getSelectedQuote() async -> ExpressAvailabilityQuoteState?
    func updateSelectedProvider(provider: ExpressProvider) async throws -> ExpressManagerState

    func update() async throws -> ExpressManagerState
}
