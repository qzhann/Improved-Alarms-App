//
//  Array+Helpers.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/30/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    /// Rotates an array to the left so that the element at index`degree` becomes the first element.
    func leftRotated(degree: Int) -> Array<Element> {
        guard !self.isEmpty else { return self }
        let effectivePositiveIndex = ((abs(degree) % self.count * degree.signum()) + self.count) % self.count
        var result = Array<Element>()
        for i in effectivePositiveIndex ..< effectivePositiveIndex + self.count {
            let index = i % self.count
            result.append(self[index])
        }
        return result
    }
}

