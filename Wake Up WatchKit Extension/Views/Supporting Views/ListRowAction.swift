//
//  ListRowAction.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/3/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct ListRowActionModifier<ActionContent, SelectionValue>: ViewModifier where ActionContent: View, SelectionValue: Hashable {
    let action: () -> Void
    let actionContent: ActionContent
    @Binding private var globalSelection: SelectionValue?
    private let managedSelection: SelectionValue
    var isSelected: Bool {
        globalSelection == managedSelection
    }

    @ObservedObject var translationState = TranslationState(trailingActionEndPosition: -(screenWidth / 2) - 1)
    
    init(globalSelection: Binding<SelectionValue?>, managedSelection: SelectionValue, action: @escaping () -> Void, actionContent: ActionContent) {
        self._globalSelection = globalSelection
        self.managedSelection = managedSelection
        self.action = action
        self.actionContent = actionContent
        
        if !self.isSelected {
            self.translationState.positionState = .default
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: self.translationState.totalOffset, y: 0)
            .animation(Animation.interactiveSpring())
            .gesture(DragGesture.rowActionDragGesture(translationState))
            .simultaneousGesture(
                // changes global selection if global selection was not selecting on the managed selection
                DragGesture(minimumDistance: 16, coordinateSpace: .local)
                    .onChanged { (value) in
                        if self.globalSelection != self.managedSelection {
                            self.globalSelection = self.managedSelection
                        }
                    }
            )
            .focusable(true, onFocusChange: { (isFocused) in
                // Resets the position state on losing focus
                if !isFocused {
                    self.translationState.positionState = .default
                }
            })
            .background(
                HStack {
                    Spacer()
                    
                    actionContent
                        .brightness(self.translationState.brightnessFactor)
                        .saturation(self.translationState.saturationFactor)
                        .animation(Animation.linear(duration: 0.15))
                        // uses an linear animation here so that the brightness changes more dramatically than the scale effect. Provides user with more direct feedback that the swipe would soon cover up / reveal the row actions.
                        
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .onTapGesture { // Using `.onTapGesture` instead of `Button` to avoid duplicated gesture recognition when tapping on the row
                            self.action()
                            self.translationState.positionState = .default
                        }
                    .frame(width: screenWidth / 2 - 1)
                    .cornerRadius(listRowCornerRadius)
                    .scaleEffect(self.translationState.scaleFactor)
                    .animation(Animation.easeOut(duration: 0.15))
                    // uses an easeOut animation here so that the card changes more dramatically in size when it is about to complete its revealing or hiding
                }
                .frame(width: screenWidth)
            )
    }
}

extension View {
    /// A custom modifier which adds a row action behavior.
    /// - Parameters:
    ///   - action: The action to perform when `viewContent` is tapped.
    ///   - selectionManager: The row action selection manager used to manage row action selection exclusivity. Defaults to the `ExclusiveSelectionManager.shared`.
    ///   - viewContent: The view content being displayed as the row action.
    func listRowActionButton<ViewContent, ID>(globalSelection: Binding<ID?>, managedSelection: ID, action: @escaping () -> Void, viewContent: () -> ViewContent) -> some View where ViewContent: View, ID: Hashable {
        self.modifier(ListRowActionModifier(globalSelection: globalSelection, managedSelection: managedSelection, action: action, actionContent: viewContent()))
    }
}

struct ListRowAction_Preview: View {
    @State var globalSelection: Alarm? = Alarm.default
    var body: some View {
        List {
            // The list row action has already been applied in the AlarmCard instance
            AlarmCard(alarm: Alarm.sampleAlarms[1], globalRowActionSelection: self.$globalSelection)
        }
        .environmentObject(testUserData)
    }
}

struct ListRowAction_Previews: PreviewProvider {
    static var previews: some View {
        ListRowAction_Preview()
    }
}
