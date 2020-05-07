//
//  ListRowAction.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/3/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct ListRowActionModifier<ActionContent: View>: ViewModifier {
    let action: () -> Void
    let actionContent: ActionContent
    weak var selectionManager: RowActionSelectionManager?
    
    @ObservedObject var translationState = TranslationState(trailingActionEndPosition: -(screenWidth / 2) - 1)
    
    init(action: @escaping () -> Void, selectionManager: RowActionSelectionManager, actionContent: ActionContent) {
        self.action = action
        self.actionContent = actionContent
        self.selectionManager = selectionManager
        selectionManager.managedSelections.append(translationState)
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: self.translationState.totalOffset, y: 0)
            .animation(Animation.interactiveSpring())
            .gesture(DragGesture.rowActionDragGesture(translationState, selectionManager: selectionManager))
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
    ///   - selectionManager: The row action selection manager used to manage row action selection exclusivity. Defaults to the `RowActionSelectionManager.shared`.
    ///   - viewContent: The view content being displayed as the row action.
    func listRowActionButton<ViewContent: View>(action: @escaping () -> Void, selectionManager: RowActionSelectionManager = RowActionSelectionManager.shared, viewContent: () -> ViewContent) -> some View {
        self.modifier(ListRowActionModifier(action: action, selectionManager: selectionManager, actionContent: viewContent()))
    }
}

struct ListRowAction_Previews: PreviewProvider {
    static var previews: some View {
        List {
            // The list row action has already been applied in the AlarmCard instance
            AlarmCard(alarm: Alarm.sampleAlarms[1])
                
        }
        .environmentObject(testUserData)
    }
}
