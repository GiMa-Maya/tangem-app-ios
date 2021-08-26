//
//  CardOnboardingView.swift
//  Tangem Tap
//
//  Created by Andrew Son on 24.08.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI

struct CardOnboardingView: View {
    
    @ObservedObject var viewModel: CardOnboardingViewModel 
    
    @ViewBuilder
    var navigationLinks: some View {
        if !viewModel.isFromMainScreen {
            NavigationLink(destination: MainView(viewModel: viewModel.assembly.makeMainViewModel()),
                           isActive: $viewModel.toMain)
        }
    }
    
    @ViewBuilder
    var notScannedContent: some View {
        Text("Not scanned view")
    }
    
    @ViewBuilder
    var defaultLaunchView: some View {
        OnboardingView(viewModel: viewModel.assembly.getOnboardingViewModel())
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.content {
        case .notScanned:
            if !viewModel.isFromMainScreen {
                defaultLaunchView
            } else {
                notScannedContent
            }
        case .note:
            defaultLaunchView
        default:
            Text("Default case")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationLinks
            
            content
        }
        .navigationBarTitle(viewModel.content.navbarTitle, displayMode: .inline)
        .navigationBarHidden(!viewModel.isFromMainScreen)
    }
}

struct CardOnboardingView_Previews: PreviewProvider {
    
    static let assembly = Assembly.previewAssembly
    
    static var previews: some View {
        NavigationView {
            CardOnboardingView(
                viewModel: assembly.makeCardOnboardingViewModel(
                    with: assembly.previewNoteCardOnboardingInput)
            )
            .environmentObject(Assembly.previewAssembly.services.navigationCoordinator)
        }
    }
}

struct CardOnboardingMessagesView: View {
    
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let onTitleTapCallback: (() -> Void)?
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundColor(.tangemTapGrayDark6)
                .padding(.bottom, 14)
                .onTapGesture {
                    // TODO: Remove before create PR. This is debug feature.
                    onTitleTapCallback?()
                }
            Text(subtitle)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.tangemTapGrayDark6)
                .frame(maxWidth: .infinity)
        }
    }
    
}
