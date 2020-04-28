//
//  Weekday.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/26/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

enum Weekday: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    func offSet(by offset: Int) -> Weekday {
        let effectiveOffset = offset % Weekday.allCases.count
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

extension Weekday: Equatable, Codable {}
