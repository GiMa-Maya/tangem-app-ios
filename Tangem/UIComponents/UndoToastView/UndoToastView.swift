//
//  UndoToastView.swift
//  Tangem
//
//  Created by Sergey Balashov on 27.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct UndoToastView: View {
    let settings: UndoToastSettings
    let undoAction: () -> Void

    var body: some View {
        Button(action: undoAction) {
            HStack(spacing: 8) {
                titleView

                Rectangle()
                    .frame(width: 0.5, height: 12)
                    .foregroundColor(Colors.Stroke.secondary)

                Text(Localization.toastUndo)
                    .style(Fonts.Regular.footnote, color: Colors.Text.primary2)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Colors.Icon.secondary)
            .cornerRadiusContinuous(10)
        }
    }

    private var titleView: some View {
        HStack(spacing: 6) {
            settings.image.image
                .resizable()
                .renderingMode(.template)
                .frame(width: 18, height: 18)
                .foregroundColor(Colors.Icon.inactive)

            Text(settings.title)
                .style(Fonts.Regular.footnote, color: Colors.Text.disabled)
                .lineLimit(1)
        }
    }
}

protocol UndoToastSettings {
    var image: ImageType { get }
    var title: String { get }
}

struct UndoToastView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            UndoToastView(settings: BalanceHiddenToastType.hidden) {}

            UndoToastView(settings: BalanceHiddenToastType.shown) {}
        }
        .preferredColorScheme(.light)

        VStack {
            UndoToastView(settings: BalanceHiddenToastType.hidden) {}

            UndoToastView(settings: BalanceHiddenToastType.shown) {}
        }
        .preferredColorScheme(.dark)
    }
}