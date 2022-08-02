//
//  DefaultToggleRowView.swift
//  Tangem
//
//  Created by Sergey Balashov on 26.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct DefaultToggleRowView: View {
    let title: String
    let isEnabled: Bool
    let isOn: Binding<Bool>

    init(title: String, isEnabled: Bool = true, isOn: Binding<Bool>) {
        self.title = title
        self.isEnabled = isEnabled
        self.isOn = isOn
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(isEnabled ? Colors.Text.primary1 : Colors.Text.disabled)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyleCompat(Colors.Control.checked)
                .disabled(!isEnabled)
        }
    }
}