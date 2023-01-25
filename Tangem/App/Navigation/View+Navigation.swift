//
//  View+Navigation.swift
//  Recipes
//
//  Created by Paul Kraft on 05.01.21.
//

import SwiftUI

// MARK: - Push/pop navigation

extension View {
    func onNavigation(_ action: @escaping () -> Void) -> some View {
        let isActive = Binding(
            get: { false },
            set: { newValue in
                if newValue {
                    action()
                }
            }
        )
        return NavigationLink(
            destination: EmptyView(),
            isActive: isActive
        ) {
            self
        }
    }

    func onNavigation<Tag: Hashable>(_ action: @escaping () -> Void, tag: Tag, selection: Binding<Tag?>) -> some View {
        let isActiveSelection = Binding<Tag?>(
            get: { nil },
            set: { newValue in
                selection.wrappedValue = newValue
                if newValue != nil {
                    action()
                }
            }
        )
        return NavigationLink(
            destination: EmptyView(),
            tag: tag,
            selection: isActiveSelection
        ) {
            self
        }
    }

    func navigation<Item, Destination: View>(
        item: Binding<Item?>,
        @ViewBuilder destination: (Item) -> Destination
    ) -> some View {
        let isActive = Binding(
            get: { item.wrappedValue != nil },
            set: { value in
                if !value {
                    item.wrappedValue = nil
                }
            }
        )
        return navigation(isActive: isActive) {
            item.wrappedValue.map(destination)
        }
    }

    func navigation<Destination: View>(
        isActive: Binding<Bool>,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        overlay(
            NavigationLink(
                destination: isActive.wrappedValue ? destination() : nil,
                isActive: isActive,
                label: { EmptyView() }
            )
        )
    }

    func navigationLinks<Links: View>(_ links: Links) -> some View {
        background(links)
    }

    /// Fixes ios13 single link issue
    func emptyNavigationLink() -> some View {
        navigation(item: .constant(nil)) {
            EmptyView()
        }
    }
}

// MARK: - Bottom sheet

extension View {
    @ViewBuilder
    func bottomSheet<Item, ContentView: View>(
        item: Binding<Item?>,
        settings: BottomSheetContainer<Item, ContentView>.Settings = .init(),
        @ViewBuilder content: @escaping (Item) -> ContentView
    ) -> some View {
        let isShowing = Binding<Bool>(
            get: { item.wrappedValue != nil },
            set: { isShow in
                if !isShow {
                    item.wrappedValue = nil
                }
            }
        )

        BottomSheetContainer(isVisible: isShowing, settings: settings) {
            item.wrappedValue.map(content)
        }
    }

    @ViewBuilder
    func bottomSheet<Item, ContentView: View>(
        isShowing: Binding<Bool>,
        settings: BottomSheetContainer<Item, ContentView>.Settings = .init(),
        @ViewBuilder content: @escaping () -> ContentView
    ) -> some View {
        BottomSheetContainer(isVisible: isShowing, settings: settings, content: content)
    }
}

extension NavigationLink {
    init<T: Identifiable, D: View>(
        item: Binding<T?>,
        @ViewBuilder destination: (T) -> D,
        @ViewBuilder label: () -> Label
    ) where Destination == D? {
        let isActive = Binding(
            get: { item.wrappedValue != nil },
            set: { value in
                if !value {
                    item.wrappedValue = nil
                }
            }
        )
        self.init(
            destination: item.wrappedValue.map(destination),
            isActive: isActive,
            label: label
        )
    }
}
