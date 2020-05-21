//
//  SupportingAlarmState.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/19/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

enum SnoozeState {
    case off
    case duration(minutes: Int)
}

/// an array of states including `.off`, and `.duration` starting from 1 and ending at 60, incremented by one minute for each element.
let allSnoozeStates: [SnoozeState] = {
    var states = [SnoozeState]()
    states.append(.off)
    for duration in 1...60 {
        states.append(.duration(minutes: duration))
    }
    return states
}()

enum SleepReminderState {
    case off
    case duration(hours: Int)
}

/// an array of states including `.off`, and `.duration` starting from 1 and ending at 23, incremented by one hour for each element.
let allSleepReminderStates: [SleepReminderState] = {
    var states = [SleepReminderState]()
    states.append(.off)
    for duration in 1..<24 {
        states.append(.duration(hours: duration))
    }
    return states
}()

// MARK: - Basic behavior protocols

extension SnoozeState: Equatable, Hashable {}
extension SleepReminderState: Equatable, Hashable {}

extension SnoozeState: CustomStringConvertible {
    var description: String {
        switch self {
        case .off:
            return "Off"
        case .duration(minutes: let duration):
            if duration == 1 {
                return "\(duration) min "
            } else {
                return "\(duration) mins"
            }
        }
    }
}
extension SleepReminderState: CustomStringConvertible {
    var description: String {
        switch self {
        case .off:
            return "Off"
        case .duration(hours: let duration):
            if duration == 1 {
                return "\(duration) hr "
            } else {
                return "\(duration) hrs"
            }
        }
    }
}

extension SnoozeState: Codable {
    enum CodingKeys: String, CodingKey {
        case off, duration
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .off:
            try container.encode("", forKey: .off)
        case .duration(minutes: let minutes):
            try container.encode(minutes, forKey: .duration)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let minutes = try? container.decode(Int.self, forKey: .duration) {
            self = .duration(minutes: minutes)
        } else {
            self = .off
        }
    }
}

extension SleepReminderState: Codable {
    enum CodingKeys: String, CodingKey {
        case off, duration
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .off:
            try container.encode("", forKey: .off)
        case .duration(hours: let hours):
            try container.encode(hours, forKey: .duration)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let hours = try? container.decode(Int.self, forKey: .duration) {
            self = .duration(hours: hours)
        } else {
            self = .off
        }
    }
}
