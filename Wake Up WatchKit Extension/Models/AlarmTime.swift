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
    var previous: Weekday {
        return Weekday(rawValue: (self.rawValue - 1 + Weekday.allCases.count) % Weekday.allCases.count)!
    }
}

/// An encapsulation of time.
struct AlarmTime {
    var day: Weekday
    var hour: Int
    var minute: Int
}
