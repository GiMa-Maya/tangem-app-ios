//
//  UnstakingFlowBaseBuilder.swift
//  Tangem
//
//  Created by Sergey Balashov on 26.07.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import TangemStaking

struct UnstakingFlowBaseBuilder {
    let userWalletModel: UserWalletModel
    let walletModel: WalletModel
    let sendAmountStepBuilder: SendAmountStepBuilder
    let sendFeeStepBuilder: SendFeeStepBuilder
    let sendSummaryStepBuilder: SendSummaryStepBuilder
    let sendFinishStepBuilder: SendFinishStepBuilder
    let builder: SendDependenciesBuilder

    func makeSendViewModel(manager: any StakingManager, router: SendRoutable) -> SendViewModel {
        let notificationManager = builder.makeSendNotificationManager()
        let sendTransactionDispatcher = builder.makeSendTransactionDispatcher()
        let unstakingModel = builder.makeUnstakingModel(
            stakingManager: manager,
            sendTransactionDispatcher: sendTransactionDispatcher
        )

        let sendFeeCompactViewModel = sendFeeStepBuilder.makeSendFeeCompactViewModel(input: unstakingModel)
        sendFeeCompactViewModel.bind(input: unstakingModel)

        let sendAmountCompactViewModel = sendAmountStepBuilder.makeSendAmountCompactViewModel(input: unstakingModel)

        let summary = sendSummaryStepBuilder.makeSendSummaryStep(
            io: (input: unstakingModel, output: unstakingModel),
            actionType: .unstake,
            sendTransactionDispatcher: sendTransactionDispatcher,
            notificationManager: notificationManager,
            editableType: .noEditable,
            sendDestinationCompactViewModel: .none,
            sendAmountCompactViewModel: sendAmountCompactViewModel,
            stakingValidatorsCompactViewModel: .none,
            sendFeeCompactViewModel: sendFeeCompactViewModel
        )

        let finish = sendFinishStepBuilder.makeSendFinishStep(
            input: unstakingModel,
            sendDestinationCompactViewModel: .none,
            sendAmountCompactViewModel: sendAmountCompactViewModel,
            stakingValidatorsCompactViewModel: .none,
            sendFeeCompactViewModel: sendFeeCompactViewModel
        )

        let stepsManager = CommonUnstakingStepsManager(
            summaryStep: summary.step,
            finishStep: finish
        )

        let interactor = CommonSendBaseInteractor(
            input: unstakingModel,
            output: unstakingModel,
            walletModel: walletModel,
            emailDataProvider: userWalletModel
        )

        let viewModel = SendViewModel(
            interactor: interactor,
            stepsManager: stepsManager,
            userWalletModel: userWalletModel,
            feeTokenItem: walletModel.feeTokenItem,
            coordinator: router
        )
        stepsManager.set(output: viewModel)

        return viewModel
    }
}