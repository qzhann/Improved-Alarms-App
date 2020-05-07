//
//  Gesture+Helpers.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/6/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

extension DragGesture {
    /// Returns a row action drag gesture that binds to a translation state.
    static func rowActionDragGesture(_ translationState: Binding<TranslationState>) -> some Gesture {
        let rowActionGesture = DragGesture(minimumDistance: 12.0, coordinateSpace: .local)
        .onChanged { (value) in
            let translation = value.location.x - value.startLocation.x
            var currentState = translationState.wrappedValue
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
            translationState.wrappedValue = currentState
            
        }
        .onEnded { (value) in
            let translation = value.location.x - value.startLocation.x
            let finalPosition = translation + translationState.wrappedValue.stablePosition
            var currentState = translationState.wrappedValue

            if finalPosition > currentState.defaultPosition {  // Over default position
                currentState.positionState = .default
            } else if finalPosition < currentState.trailingActionEndPosition {   // Over the trailing action end position
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
            translationState.wrappedValue = currentState
            
        }
        
        return rowActionGesture
    }
}

/// Represents the state of the translation induced by the drag gesture.
struct TranslationState {
    var id: UUID
    
    enum PositionState {
        case `default`
        case showingTrailingAction
        case showingLeadingAction
    }
    
    init(trailingActionEndPosition: CGFloat) {
        self.trailingActionEndPosition = trailingActionEndPosition
        self.id = UUID()
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
