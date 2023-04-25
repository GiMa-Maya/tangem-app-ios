//
//  VIew+.swift
//  Tangem
//
//  Created by Alexander Osokin on 02.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension View {
    func toAnyView() -> AnyView {
        AnyView(self)
    }

    @ViewBuilder
    func tintCompat(_ color: Color) -> some View {
        if #available(iOS 15.0, *) {
            self.tint(color)
        } else {
            self
        }
    }

    @ViewBuilder
    func toggleStyleCompat(_ color: Color) -> some View {
        if #available(iOS 15.0, *) {
            self.tint(color)
        } else {
            toggleStyle(SwitchToggleStyle(tint: color))
        }
    }

    @ViewBuilder
    func searchableCompat(text: Binding<String>) -> some View {
        if #available(iOS 15.0, *) {
            self.searchable(text: text, placement: .navigationBarDrawer(displayMode: .always))
        } else {
            self
        }
    }

    @ViewBuilder
    func interactiveDismissDisabledCompat() -> some View {
        if #available(iOS 15, *) {
            self.interactiveDismissDisabled()
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
