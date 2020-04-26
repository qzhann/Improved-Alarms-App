//
//  AlarmTime.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/24/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

enum Weekday: Int, CaseIterable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    
    func offSet(by offset: Int) -> Weekday {
        let effectiveOffset = offset % Weekday.allCases.count
        return Weekday(rawValue: (self.rawValue + effectiveOffset + Weekday.allCases.count) % Weekday.allCases.count)!
    }
    
    var previous: Weekday {
        return self.offSet(by: -1)
    }
}

/// An encapsulation of time.
struct AlarmTime {
    var day: Weekday
    var hour: Int
    var minute: Int
}

extension Weekday: Equatable, Codable {}

extension AlarmTime: Equatable, Codable {}

