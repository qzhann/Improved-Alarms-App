//
//  SelectionManaging.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/7/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation
import SwiftUI

protocol Selectable {
    func select()
    func deselect()
}

/// A Manager class that ensures exclusive selection among an array of values to select from.
protocol SelectionManaging: AnyObject {
    associatedtype SelectionValue: Identifiable, Selectable
    
    var managedSelections: [SelectionValue] { get set }
    var currentSelection: SelectionValue? { get set }
    func addManagedSelection(_ selection: SelectionValue)
    func changeSelection(_ selection: SelectionValue?)
}

protocol ExclusiveSelectionManaging: SelectionManaging {}
extension ExclusiveSelectionManaging {
    func addManagedSelection(_ selection: SelectionValue) {
        managedSelections.append(selection)
    }
    func changeSelection(_ selection: SelectionValue?) {
        // Update current selection if it changes, and deselect all other selections
        if currentSelection?.id != selection?.id {
            currentSelection = selection
            currentSelection?.select()
            for index in managedSelections.indices {
                if managedSelections[index].id != currentSelection?.id {
                    managedSelections[index].deselect()
                }
            }
        }
    }
}

/// When used together with a `SelectionManaging`, `SelectionItem` provides a default mechanism for a `View` to create dependencies on its selection state by using `SelectionItem` as a source of truth.
class SelectionItem: ObservableObject, Identifiable, Selectable {
    let id = UUID()
    @Published var isSelected: Bool
    
    init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func select() {
        isSelected = true
    }
    
    func deselect() {
        isSelected = false
    }
}

/// Manages the selection of multiple identifiable items and ensures that at most one selection is allowed at a time.
class ExclusiveSelectionManager: ExclusiveSelectionManaging {
    
    var managedSelections: [SelectionItem] = []
    var currentSelection: SelectionItem?
    
    static var shared: ExclusiveSelectionManager = {
        ExclusiveSelectionManager()
    }()
}

/// Manages the selection of row action more delicately than `ExclusiveSelectionManager`, ensuring that only one row action is displayed.
class RowActionSelectionManager: ExclusiveSelectionManaging {
    
    var managedSelections: [TranslationState] = []
    var currentSelection: TranslationState?
    
    /// A shared instance of row action selection manager.
    static var shared: RowActionSelectionManager = {
        RowActionSelectionManager()
    }()
}
