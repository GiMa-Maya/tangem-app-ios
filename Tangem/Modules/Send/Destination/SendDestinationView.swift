//
//  SendDestinationView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct SendDestinationView: View {
    let namespace: Namespace.ID
    @ObservedObject var viewModel: SendDestinationViewModel

    let bottomSpacing: CGFloat

    var body: some View {
        GroupedScrollView(spacing: 20) {
            if let addressViewModel = viewModel.addressViewModel {
                GroupedSection(addressViewModel) {
                    SendDestinationTextView(viewModel: $0)
                        .setNamespace(namespace)
                        .setContainerNamespaceId(SendViewNamespaceId.addressContainer.rawValue)
                        .setTitleNamespaceId(SendViewNamespaceId.addressTitle.rawValue)
                        .setIconNamespaceId(SendViewNamespaceId.addressIcon.rawValue)
                        .setTextNamespaceId(SendViewNamespaceId.addressText.rawValue)
                        .setClearButtonNamespaceId(SendViewNamespaceId.addressClearButton.rawValue)
                        //
                        .opacity(viewModel.showSectionContent ? 1 : 0)
                } footer: {
                    if !addressViewModel.animatingFooterOnAppear {
                        Text(addressViewModel.description)
                            .style(Fonts.Regular.caption1, color: Colors.Text.tertiary)
                            .transition(SendView.Constants.auxiliaryViewTransition)
                    }
                }
                .innerContentPadding(2)
                .backgroundColor(Colors.Background.action, id: SendViewNamespaceId.addressContainer.rawValue, namespace: namespace)
            }

            if let additionalFieldViewModel = viewModel.additionalFieldViewModel {
                GroupedSection(additionalFieldViewModel) {
                    SendDestinationTextView(viewModel: $0)
                        .opacity(viewModel.showSectionContent ? 1 : 0)
                } footer: {
                    if !additionalFieldViewModel.animatingFooterOnAppear {
                        Text(additionalFieldViewModel.description)
                            .style(Fonts.Regular.caption1, color: Colors.Text.tertiary)
                            .transition(SendView.Constants.auxiliaryViewTransition)
                    }
                }
                .innerContentPadding(2)
                .backgroundColor(Colors.Background.action)
            }

            if let suggestedDestinationViewModel = viewModel.suggestedDestinationViewModel, viewModel.showSuggestedDestinations {
                SendSuggestedDestinationView(viewModel: suggestedDestinationViewModel)
                    .transition(.opacity)
            }

            Spacer(minLength: bottomSpacing)
        }
        .background(Colors.Background.tertiary.edgesIgnoringSafeArea(.all))
        .onAppear(perform: viewModel.onSectionContentAppear)
        .onDisappear(perform: viewModel.onSectionContentDisappear)
        .onAppear(perform: viewModel.onAuxiliaryViewAppear)
        .onDisappear(perform: viewModel.onAuxiliaryViewDisappear)
    }
}

struct SendDestinationView_Previews: PreviewProvider {
    @Namespace static var namespace

    static var previews: some View {
        SendDestinationView(namespace: namespace, viewModel: SendDestinationViewModel(input: SendDestinationViewModelInputMock()), bottomSpacing: 150)
    }
}
