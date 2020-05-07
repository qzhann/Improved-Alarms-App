//
//  View+Helpers.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/3/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

var screenWidth: CGFloat {
    return 175
}

var listRowCornerRadius: CGFloat {
    return 8.5
}

protocol Deselectable {
    func deselect()
}

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
