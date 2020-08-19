//
//  PropertyWrappers.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/22/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

/// A struct that monitors changes for `wrappedCollection`and each element it contains. `PublishedCollection` will emit via its projected value when `wrappedCollection` or any of its element changes.
/// To monitor changes in the wrapped value, listen for changes from the projected value.
@propertyWrapper
struct PublishedCollection<CollectionType> where CollectionType: Collection, CollectionType.Element: ObservableObject {
    var wrappedCollection: CollectionType
    var cancellables: [AnyCancellable]?

    var wrappedValue: CollectionType {
        get { return wrappedCollection }
        set {
            wrappedCollection = newValue
            self.cancellables = cancellablesForSubscribing(to: wrappedCollection, subject: projectedValue)
            self.projectedValue.send()  // send changes when `wrappedValue` will change.
        }
    }
    var projectedValue: PassthroughSubject<Void, Never>
    
    init(wrappedValue: CollectionType) {
        self.wrappedCollection = wrappedValue
        self.projectedValue = PassthroughSubject<Void, Never>()
        self.cancellables = cancellablesForSubscribing(to: wrappedValue, subject: projectedValue)
    }
    
    /// Returns an array of cancellable objects corresponding to the subscription to each element in the collection.
    /// - Parameters:
    ///   - collection: The collection that you want to monitor changes for.
    ///   - subject: The subject that sends the changes.
    /// - Returns: An array of cancellable objects corresponding to the subscription to each element in the collection.
    func cancellablesForSubscribing(to collection: CollectionType, subject: PassthroughSubject<Void, Never>) -> [AnyCancellable] {
        var results = [AnyCancellable]()
        results.reserveCapacity(collection.count)
        // observe the change in each element
        for observableElement in collection {
            results.append(
                observableElement.objectWillChange
                    .sink { _ in self.projectedValue.send() }
            )
        }
        return results
    }
    
}
