//
//  ListRowAction.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/3/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct ListRowActionModifier<ViewContent: View>: ViewModifier {
    let action: () -> Void
    let viewContent: ViewContent
    
    @State var translationState = TranslationState(endPosition: -(screenWidth / 2) - 1)
    
    func body(content: Content) -> some View {
        let dragToRevealGesture = DragGesture(minimumDistance: 15.0, coordinateSpace: .local)
        .onChanged { (value) in
            let relativePosition = value.location.x - value.startLocation.x
            self.translationState.translation = relativePosition
        }
        .onEnded { (value) in
            var relativePosition = value.location.x - value.startLocation.x
            relativePosition += self.translationState.originalPosition == self.translationState.endPosition ? self.translationState.endPosition : self.translationState.startPosition
            
            let distanceToStartPosition = abs(relativePosition - self.translationState.startPosition)
            let distanceToEndPosition = abs(relativePosition - self.translationState.endPosition)
            
            var currentState = self.translationState
            if distanceToEndPosition <= distanceToStartPosition {   // Closer to end position, go to end
                withAnimation(.interactiveSpring()) {
                    currentState.originalPosition = self.translationState.endPosition
                    currentState.translation = 0
                    self.translationState = currentState
                }
            } else {    // Closer to start position, go to start
                withAnimation(.interactiveSpring()) {
                    currentState.originalPosition = self.translationState.startPosition
                    currentState.translation = 0
                    self.translationState = currentState
                }
            }
        }
        
        return content
            .offset(x: self.translationState.total, y: 0)
            .gesture(dragToRevealGesture)
            .background(
                HStack {
                    Spacer()
                    
                    viewContent
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .onTapGesture { // Using `.onTapGesture` instead of `Button` to avoid duplicated gesture recognition when tapping on the row
                            self.action()
                        }
                    .frame(width: screenWidth / 2 - 1)
                    .cornerRadius(listRowCornerRadius)
                }
                .frame(width: screenWidth)
            )
    }
}

extension View {
    /// A custom modifier which adds a row action behavior.
    func listRowActionButton<ViewContent: View>(action: @escaping () -> Void, viewContent: () -> ViewContent) -> some View {
        self.modifier(ListRowActionModifier(action: action, viewContent: viewContent()))
    }
}

struct TranslationState {
    var translation: CGFloat = 0.0
    var originalPosition: CGFloat = 0.0
    var startPosition: CGFloat = 0.0
    var endPosition: CGFloat
    
    var total: CGFloat {
        translation + originalPosition
    }
}

struct ListRowAction_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AlarmCard(alarm: Alarm.sampleAlarms[1])
                .listRowBackgroundColor(.orange)
                .listRowActionButton(action: {}) {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 33, weight: .medium))
                        .foregroundColor(.secondaryTextColor(for: Alarm.sampleAlarms[1], in: testUserData))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .background(Color.gray)
                }
                
        }
        .environmentObject(testUserData)
    }
}
