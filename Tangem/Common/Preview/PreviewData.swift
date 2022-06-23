//
//  PreviewData.swift
//  Tangem
//
//  Created by Andrew Son on 25.08.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk

struct PreviewData {
    static var previewNoteCardOnboardingInput: OnboardingInput {
        OnboardingInput(steps: .singleWallet([.createWallet, .success]),
                        cardInput: .cardModel(PreviewCard.cardanoNote.cardModel),
                        cardsPosition: nil,
                        welcomeStep: nil,
                        currentStepIndex: 0)
    }
    
    static var previewTwinOnboardingInput: OnboardingInput {
        .init(steps: .twins([.intro(pairNumber: "0128"),
                             .first, .second, .third,
                             .topup, .done]),
              cardInput: .cardModel(PreviewCard.twin.cardModel),
              cardsPosition: nil,
              welcomeStep: nil,
              currentStepIndex: 0)
    }
    
    static var previewWalletOnboardingInput: OnboardingInput {
        .init(steps: .wallet([.createWallet, .backupIntro, .selectBackupCards, .backupCards, .success]),
              cardInput: .cardModel(PreviewCard.tangemWalletEmpty.cardModel),
              cardsPosition: nil,
              welcomeStep: nil,
              currentStepIndex: 0)
    }
}
