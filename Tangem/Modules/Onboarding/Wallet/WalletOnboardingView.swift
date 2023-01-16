//
//  WalletOnboardingView.swift
//  Tangem
//
//  Created by Andrew Son on 22.09.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI

struct WalletOnboardingView: View {
    @ObservedObject var viewModel: WalletOnboardingViewModel

    private let screenSize: CGSize = UIScreen.main.bounds.size
    private let infoPagerHeight: CGFloat = 146

    var currentStep: WalletOnboardingStep {
        viewModel.currentStep
    }

    var isNavbarVisible: Bool {
        viewModel.isNavBarVisible
    }

    var isProgressBarVisible: Bool {
        if case .welcome = currentStep {
            return false
        }

        if !viewModel.isInitialAnimPlayed {
            return false
        }

        return true
    }

    var secondCardPlaceholder: OnboardingCardView.CardType {
        .dark
    }

    @ViewBuilder
    var customContent: some View {
        switch viewModel.currentStep {
        case .saveUserWallet:
            UserWalletStorageAgreementView(viewModel: viewModel.userWalletStorageAgreementViewModel)
        case .enterPin:
            EnterPinView(text: $viewModel.pinText,
                         title: viewModel.currentStep.title!,
                         subtitle: viewModel.currentStep.subtitle!,
                         maxDigits: SaltPayRegistrator.Constants.pinLength)
        case .registerWallet:
            CustomContentView(imageName: "cards_wallet",
                              title: viewModel.currentStep.title!,
                              subtitle: viewModel.currentStep.subtitle!)
        case .kycStart:
            CustomContentView(imageName: "passport",
                              title: viewModel.currentStep.title!,
                              subtitle: viewModel.currentStep.subtitle!)
        case .kycProgress:
            if let kycModel = viewModel.kycModel {
                WebViewContainer(viewModel: kycModel)
            }
        case .kycWaiting:
            KYCView(imageName: "success_waiting",
                    title: viewModel.currentStep.title!,
                    subtitle: viewModel.currentStep.subtitle!)
        case .kycRetry:
            KYCView(imageName: "error_circle",
                    title: viewModel.currentStep.title!,
                    subtitle: viewModel.currentStep.subtitle!)
        default:
            EmptyView()
        }
    }

    var body: some View {
        ZStack {
            ConfettiView(shouldFireConfetti: $viewModel.shouldFireConfetti)
                .allowsHitTesting(false)
                .frame(maxWidth: screenSize.width)
                .zIndex(110)

            VStack(spacing: 0) {
                GeometryReader { geom in
                    let size = geom.size
                    ZStack(alignment: .center) {
                        // Navbar is added to ZStack instead of VStack because of wrong animation when container changed
                        // and cards jumps instead of smooth transition
                        NavigationBar(title: viewModel.navbarTitle,
                                      settings: .init(titleFont: .system(size: 17, weight: .semibold), backgroundColor: .clear),
                                      leftItems: {
                                          BackButton(height: viewModel.navbarSize.height,
                                                     isVisible: viewModel.isBackButtonVisible,
                                                     isEnabled: viewModel.isBackButtonEnabled) {
                                              viewModel.backButtonAction()
                                          }
                                      },
                                      rightItems: {
                                          ChatButton(height: viewModel.navbarSize.height,
                                                     isVisible: true,
                                                     isEnabled: true) {
                                              viewModel.openSupportChat()
                                          }
                                      })
                                      .offset(x: 0, y: -geom.size.height / 2 + (isNavbarVisible ? viewModel.navbarSize.height / 2 + 4 : 0))
                                      .opacity(isNavbarVisible ? 1.0 : 0.0)

                        ProgressBar(height: 5, currentProgress: viewModel.currentProgress)
                            .opacity(isProgressBarVisible ? 1.0 : 0.0)
                            .frame(width: screenSize.width - 32)
                            .offset(x: 0, y: -size.height / 2 + viewModel.navbarSize.height + 10)

                        if !viewModel.isCustomContentVisible {
                            AnimatedView(settings: viewModel.$thirdCardSettings) {
                                OnboardingCardView(placeholderCardType: secondCardPlaceholder,
                                                   cardImage: viewModel.secondImage ?? viewModel.cardImage,
                                                   cardScanned: viewModel.canShowThirdCardImage && (viewModel.backupCardsAddedCount >= 2 || currentStep == .backupIntro) && viewModel.canDisplayCardImage)
                            }

                            AnimatedView(settings: viewModel.$supplementCardSettings) {
                                OnboardingCardView(placeholderCardType: secondCardPlaceholder,
                                                   cardImage: viewModel.secondImage ?? viewModel.cardImage,
                                                   cardScanned: (viewModel.backupCardsAddedCount >= 1 || currentStep == .backupIntro) && viewModel.canDisplayCardImage)
                            }

                            AnimatedView(settings: viewModel.$mainCardSettings) {
                                ZStack(alignment: .topTrailing) {
                                    OnboardingCardView(placeholderCardType: .dark,
                                                       cardImage: viewModel.cardImage,
                                                       cardScanned: viewModel.isInitialAnimPlayed && currentStep != .welcome)
                                    Text("common_origin_card")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 5)
                                        .background(Color.white.opacity(0.25))
                                        .cornerRadius(50)
                                        .zIndex(251)
                                        .padding(12)
                                        .opacity(viewModel.canShowOriginCardLabel ? 1.0 : 0.0)
                                }

                            }

                            let backgroundFrame = viewModel.isInitialAnimPlayed ? currentStep.cardBackgroundFrame(containerSize: size) : .zero
                            let backgroundOffset = viewModel.isInitialAnimPlayed ? currentStep.backgroundOffset(in: size) : .zero

                            OnboardingTopupBalanceView(
                                backgroundFrameSize: backgroundFrame,
                                cornerSize: currentStep.cardBackgroundCornerRadius(containerSize: size),
                                backgroundOffset: backgroundOffset,
                                balance: viewModel.cardBalance,
                                balanceUpdaterFrame: backgroundFrame,
                                balanceUpdaterOffset: backgroundOffset,
                                refreshAction: viewModel.onRefresh,
                                refreshButtonState: viewModel.refreshButtonState,
                                refreshButtonSize: .medium,
                                refreshButtonOpacity: currentStep.balanceStackOpacity
                            )

                            OnboardingCircleButton(refreshAction: {},
                                                   state: currentStep.successCircleState,
                                                   size: .huge)
                                .offset(y: 8)
                                .opacity(currentStep.successCircleOpacity)

                            if viewModel.isInfoPagerVisible {
                                OnboardingWalletInfoPager(animated: viewModel.isInfoPagerVisible)
                                    .offset(.init(width: 0, height: size.height / 2 + infoPagerHeight / 2))
                                    .frame(height: infoPagerHeight)
                                    .zIndex(150)
                                    .transition(.opacity)
                            }
                        }
                    }
                    .position(x: size.width / 2, y: size.height / 2)
                }
                .readSize { size in
                    if !viewModel.isCustomContentVisible {
                        viewModel.setupContainer(with: size)
                    }
                }
                .frame(minHeight: viewModel.navbarSize.height + 20)


                if viewModel.isCustomContentVisible {
                    customContent
                        .layoutPriority(1)
                        .readSize { size in
                            viewModel.setupContainer(with: size)
                        }
                }

                if viewModel.isButtonsVisible {
                    OnboardingTextButtonView(
                        title: viewModel.title,
                        subtitle: viewModel.subtitle,
                        textOffset: currentStep.messagesOffset,
                        buttonsSettings: .init(main: viewModel.mainButtonSettings,
                                               supplement: viewModel.supplementButtonSettings),
                        infoText: viewModel.infoText
                    ) {
                        viewModel.closeOnboarding()
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                }
            }
        }
        .alert(item: $viewModel.alert, content: { alertBinder in
            alertBinder.alert
        })
        .preference(key: ModalSheetPreferenceKey.self, value: viewModel.isModal)
        .onAppear(perform: viewModel.onAppear)
    }
}

struct WalletOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletOnboardingView(viewModel: .init(input: PreviewData.previewWalletOnboardingInput, coordinator: OnboardingCoordinator()))
                .navigationBarHidden(true)
        }
    }
}
