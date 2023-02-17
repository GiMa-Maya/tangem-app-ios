//
//  AnalyticsEvent.swift
//  Tangem
//
//  Created by Andrew Son on 24/10/22.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

extension Analytics {
    enum CardScanSource {
        case welcome
        case auth
        case main
        case myWallets

        var cardScanButtonEvent: Analytics.Event {
            switch self {
            case .welcome:
                return .introductionProcessButtonScanCard
            case .auth:
                return .buttonCardSignIn
            case .main:
                return .buttonScanCard
            case .myWallets:
                return .buttonScanNewCard
            }
        }

        var cardWasScannedParameterValue: Analytics.ParameterValue {
            switch self {
            case .welcome:
                return .scanSourceWelcome
            case .auth:
                return .scanSourceAuth
            case .main:
                return .scanSourceMain
            case .myWallets:
                return .scanSourceMyWallets
            }
        }
    }
}
