//
//  SelectionManager.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/7/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

protocol Deselectable {
    func deselect()
}

/// A Manager that ensures exclusive selection among an array of values to select from.
protocol SelectionManager {
    associatedtype SelectionValue: Equatable, Deselectable
    var managedSelections: [SelectionValue] { get set }
    var currentSelection: SelectionValue? { get set}
}

/// Manages the selection of row action, ensuring that only one row action is displayed.
class RowActionSelectionManager: SelectionManager {
    var managedSelections: [TranslationState] = []
    var currentSelection: TranslationState? {
        didSet {
            //
            if currentSelection != oldValue {
                for index in managedSelections.indices {
                    if managedSelections[index] != currentSelection {
                        managedSelections[index].deselect()
                    }
                }
            }
        }
    }
    /// A shared instance of row action selection manager.
    static var shared: RowActionSelectionManager = {
        RowActionSelectionManager()
    }()
}
