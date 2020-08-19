//
//  ListRowAction.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/3/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

extension View {
    /// A custom modifier which adds a row action behavior.
    /// - Parameters:
    ///   - action: The action to perform when `viewContent` is tapped.
    ///   - selectionManager: The row action selection manager used to manage row action selection exclusivity. Defaults to the `ExclusiveSelectionManager.shared`.
    ///   - viewContent: The view content being displayed as the row action.
    func listRowActionButton<ViewContent, SelectionValue>(globalSelection: Binding<SelectionValue?>, tag: SelectionValue, action: @escaping () -> Void, viewContent: () -> ViewContent) -> some View where ViewContent: View, SelectionValue: Hashable {
        self.modifier(ListRowActionModifier(globalSelection: globalSelection, tag: tag, action: action, actionContent: viewContent()))
    }
}

struct ListRowActionModifier<ActionContent, SelectionValue>: ViewModifier where ActionContent: View, SelectionValue: Hashable {
    let action: () -> Void
    let actionContent: ActionContent
    
    // exclusive picker selection managing
    @Binding private var globalSelection: SelectionValue?
    private let tag: SelectionValue
    var isSelected: Bool {
        globalSelection == tag
    }

    @ObservedObject var translationState = TranslationState(trailingActionEndPosition: -(screenWidth / 2) - 1.5)
    
    init(globalSelection: Binding<SelectionValue?>, tag: SelectionValue, action: @escaping () -> Void, actionContent: ActionContent) {
        self._globalSelection = globalSelection
        self.tag = tag
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
                        if self.globalSelection != self.tag {
                            self.globalSelection = self.tag
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
                        .onTapGesture { // Using `.onTapGesture` instead of `Button` to avoid unintended gesture recognition when tapping on the row content instead of the row action content
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

struct ListRowAction_Preview: View {
    @State var globalSelection: Int?
    let alarmDay = AlarmDay.sampleAlarmDays[3]
    var body: some View {
        List {
            // The list row action has already been applied in the AlarmCard instance
            AlarmDayCard(alarmDay: alarmDay, globalSelection: self.$globalSelection, tag: testUserData.alarmDays.firstIndex(of: alarmDay)!)
        }
        .environmentObject(testUserData)
    }
}

struct ListRowAction_Previews: PreviewProvider {
    static var previews: some View {
        ListRowAction_Preview()
    }
}
