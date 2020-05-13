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
    static func rowActionDragGesture(_ translationState: TranslationState, selectionManager: RowActionSelectionManager?) -> some Gesture {
        let rowActionGesture = DragGesture(minimumDistance: 16.0, coordinateSpace: .local)
        .onChanged { (value) in
            selectionManager?.changeSelection(translationState)
            let translation = value.location.x - value.startLocation.x
            if translationState.totalOffset > translationState.defaultPosition {  // over the default position, scrub with interpolation
                switch translationState.positionState {
                case .default:
                    translationState.translation = translation / 4
                case .showingTrailingAction:
                    translationState.translation = abs(translationState.trailingActionEndPosition - translationState.defaultPosition) + (translation - abs(translationState.trailingActionEndPosition)) / 4
                case .showingLeadingAction:
                    fatalError("Did not implement showing leading action")
                }
            } else if translationState.totalOffset < translationState.trailingActionEndPosition {  // Went over the trailing action end position, scrub with interpolation
                switch translationState.positionState {
                case .default:
                    translationState.translation = translationState.trailingActionEndPosition + (translation - translationState.trailingActionEndPosition) / 4
                case .showingTrailingAction:
                    translationState.translation = translation / 4
                case .showingLeadingAction:
                    fatalError("Did not implement showing leading action")
                }
            } else {    // In the middle, scrub linearly
                translationState.translation = translation
            }
            
        }
        .onEnded { (value) in
            let translation = value.location.x - value.startLocation.x
            let finalPosition = translation + translationState.stablePosition

            if finalPosition > translationState.defaultPosition {  // Over default position
                translationState.positionState = .default
                selectionManager?.changeSelection(nil)
            } else if finalPosition < translationState.trailingActionEndPosition {   // Over the trailing action end position
                translationState.positionState = .showingTrailingAction
            } else {
                let triggerFactor: CGFloat = 0.3
                let trailingActionStateChangeThreashold = abs(translationState.defaultPosition - translationState.trailingActionEndPosition) * triggerFactor
                // Between default position and trailing action end position
                switch translationState.positionState {
                case .default:
                    if abs(translation) > trailingActionStateChangeThreashold {
                        translationState.positionState = .showingTrailingAction
                    } else {
                        translationState.positionState = .default
                        selectionManager?.changeSelection(nil)
                    }
                case .showingTrailingAction:
                    if abs(translation) > trailingActionStateChangeThreashold {
                        translationState.positionState = .default
                        selectionManager?.changeSelection(nil)
                    } else {
                        translationState.positionState = .showingTrailingAction
                    }
                case .showingLeadingAction:
                    fatalError("Did not implement showing leading action")
                }
            }
            
        }
        
        return rowActionGesture
    }
}

/// Represents the state of the translation induced by the drag gesture. Uses a class instead of a struct so that the selection manager could use translation state to keep track of the row action states.
class TranslationState: ObservableObject, Identifiable {
    let id = UUID()
    @Published var totalOffset: CGFloat = 0.0
    
    /// Repersents the current position of the row.
    enum PositionState {
        case `default`
        case showingTrailingAction
        case showingLeadingAction
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
                fatalError("Did not implement showingLeadingAction yet.")
            }
        }
    }
    
    var defaultPosition: CGFloat = 0.0
    var trailingActionEndPosition: CGFloat
    var translation: CGFloat = 0.0 {
        didSet {
            totalOffset = translation + stablePosition
        }
    }
    var stablePosition: CGFloat = 0.0 {
        didSet {
            totalOffset = translation + stablePosition
        }
    }
    
    init(trailingActionEndPosition: CGFloat) {
        self.trailingActionEndPosition = trailingActionEndPosition
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
        let returnValue = -factor + (1 - factor) * offsetFactor.clamped(min: 0, max: 1)
        return Double(returnValue)
    }
    var saturationFactor: Double {
        let factor: CGFloat = 0.1
        let returnValue = factor + (1 - factor) * offsetFactor.clamped(min: 0, max: 1)
        return Double(returnValue)
    }
}

extension TranslationState: Selectable {
    func select() {}
    
    func deselect() {
        positionState = .default
    }
}
