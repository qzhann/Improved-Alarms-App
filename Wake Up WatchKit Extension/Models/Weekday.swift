//
//  Weekday.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/26/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

/// Represents a day in a week from sunday through saturday.
enum Weekday: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    func offSet(by offset: Int) -> Weekday {
        let effectiveOffset = abs(offset) % Weekday.allCases.count * offset.signum()
        let value = ((self.rawValue + effectiveOffset + Weekday.allCases.count) - 1) % Weekday.allCases.count + 1
        guard value >= 1 && value <= 7 else { fatalError("Cannot initialize weekday with raw value \(value)") }
        return Weekday(rawValue: value)!
    }
    
    var previous: Weekday {
        return self.offSet(by: -1)
    }
}

// MARK: - View Model

extension Weekday {
    var abbreviation: String {
        switch self {
        case .monday:
            return "MON"
        case .tuesday:
            return "TUE"
        case .wednesday:
            return "WED"
        case .thursday:
            return "THUR"
        case .friday:
            return "FRI"
        case .saturday:
            return "SAT"
        case .sunday:
            return "SUN"
        }
    }
}

// MARK: - Basic behavior protocols

extension Weekday: Equatable, Codable {}

extension Weekday: Comparable {
    static func <(lhs: Weekday, rhs: Weekday) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension Weekday: CustomStringConvertible {
    var description: String {
        switch self {
        case .sunday:
            return "Sunday"
            case .monday:
            return "Monday"
            case .tuesday:
            return "Tuesday"
            case .wednesday:
            return "Wednesday"
            case .thursday:
            return "Thursday"
            case .friday:
            return "Friday"
            case .saturday:
            return "Saturday"
        }
    }
}
