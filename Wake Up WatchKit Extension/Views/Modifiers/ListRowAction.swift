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
    
    @State fileprivate var translationState = TranslationState(trailingActionEndPosition: -(screenWidth / 2) - 1)
    
    func body(content: Content) -> some View {
        let dragToRevealGesture = DragGesture(minimumDistance: 12.0, coordinateSpace: .local)
        .onChanged { (value) in
            let translation = value.location.x - value.startLocation.x
            var currentState = self.translationState
            if currentState.totalOffset > currentState.defaultPosition {  // over the default position, scrub with interpolation
                switch currentState.positionState {
                case .default:
                    currentState.translation = translation / 4
                case .showingTrailingAction:
                    currentState.translation = abs(currentState.trailingActionEndPosition - currentState.defaultPosition) + (translation - abs(currentState.trailingActionEndPosition)) / 4
                case .showingLeadingAction:
                    fatalError("Did not implement showing leading action")
                }
            } else if currentState.totalOffset < currentState.trailingActionEndPosition {  // Went over the trailing action end position, scrub with interpolation
                switch currentState.positionState {
                case .default:
                    currentState.translation = currentState.trailingActionEndPosition + (translation - currentState.trailingActionEndPosition) / 4
                case .showingTrailingAction:
                    currentState.translation = translation / 4
                case .showingLeadingAction:
                    fatalError("Did not implement showing leading action")
                }
            } else {    // In the middle, scrub linearly
                currentState.translation = translation
            }
            self.translationState = currentState
            
        }
        .onEnded { (value) in
            let translation = value.location.x - value.startLocation.x
            let finalPosition = translation + self.translationState.stablePosition
            var currentState = self.translationState

            if finalPosition > self.translationState.defaultPosition {  // Over default position
                currentState.positionState = .default
            } else if finalPosition < self.translationState.trailingActionEndPosition {   // Over the trailing action end position
                currentState.positionState = .showingTrailingAction
            } else {
                let triggerFactor: CGFloat = 0.3
                let trailingActionStateChangeThreashold = abs(currentState.defaultPosition - currentState.trailingActionEndPosition) * triggerFactor
                // Between default position and trailing action end position
                switch currentState.positionState {
                case .default:
                    if abs(translation) > trailingActionStateChangeThreashold {
                        currentState.positionState = .showingTrailingAction
                    } else {
                        currentState.positionState = .default
                    }
                case .showingTrailingAction:
                    if abs(translation) > trailingActionStateChangeThreashold {
                        currentState.positionState = .default
                    } else {
                        currentState.positionState = .showingTrailingAction
                    }
                case .showingLeadingAction:
                    fatalError("Did not implement showing leading action")
                }
                
            }
            self.translationState = currentState
            
        }
        
        return content
            .offset(x: self.translationState.totalOffset, y: 0)
            .animation(Animation.interactiveSpring())
            .gesture(dragToRevealGesture)
            .background(
                HStack {
                    Spacer()
                    
                    actionContent
                        .brightness(self.translationState.brightnessFactor)
                        .animation(Animation.linear(duration: 0.15))
                        // uses an linear animation here so that the brightness changes more dramatically than the scale effect. Provides user with more direct feedback that the swipe would soon cover up / reveal the row actions.
                        
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .onTapGesture { // Using `.onTapGesture` instead of `Button` to avoid duplicated gesture recognition when tapping on the row
                            self.action()
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
    func listRowActionButton<ViewContent: View>(action: @escaping () -> Void, viewContent: () -> ViewContent) -> some View {
        self.modifier(ListRowActionModifier(action: action, actionContent: viewContent()))
    }
}

/// Represents the state of the translation induced by the drag gesture.
fileprivate struct TranslationState {
    enum PositionState {
        case `default`
        case showingTrailingAction
        case showingLeadingAction
    }
    
    init(trailingActionEndPosition: CGFloat) {
        self.trailingActionEndPosition = trailingActionEndPosition
    }
    
    private var _positionState: PositionState = .default
        
    var positionState: PositionState {
        get { _positionState }
        set {
            self._positionState = newValue

            switch newValue {
            case .default:
                self.translation = 0
                self.stablePosition = self.defaultPosition
            case .showingTrailingAction:
                self.translation = 0
                self.stablePosition = self.trailingActionEndPosition
            case .showingLeadingAction:
                fatalError("Did not implement offTrailingEdge yet.")
            }
        }
    }
    var translation: CGFloat = 0.0
    var stablePosition: CGFloat = 0.0
    var defaultPosition: CGFloat = 0.0
    var trailingActionEndPosition: CGFloat
    
    var totalOffset: CGFloat {
        return translation + stablePosition
    }
    var offsetFactor: CGFloat {
        return totalOffset / (trailingActionEndPosition - defaultPosition)
    }
    var scaleFactor: CGFloat {
        let origionalFactor: CGFloat = 0.8
        return (origionalFactor + 0.03 + (1 - origionalFactor) * offsetFactor.clamped(min: 0, max: 1))
            .clamped(min: 0, max: 1)
            .interpolated(using: .linear)
    }
    var brightnessFactor: Double {
        let factor: CGFloat = 0.5
        let returnValue = -factor + (1 - factor) * offsetFactor
                                .clamped(min: 0, max: 1)
        return Double(returnValue)
    }
}

struct ListRowAction_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AlarmCard(alarm: Alarm.sampleAlarms[1])
                .listRowBackgroundColor(Color.orange)
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
