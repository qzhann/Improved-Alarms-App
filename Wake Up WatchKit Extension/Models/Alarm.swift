//
//  Alarm.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/24/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

/// Represents an alarm for a day.
struct Alarm {
    
    var isOn: Bool
    var isMuted: Bool
    var finalAlarmTime: AlarmTime
    var snoozeState: SnoozeState
    var departureTime: AlarmTime
    var sleepReminderState: SleepReminderState
    
    
    /// Initializes a default alarm.
    /// - Parameters:
    init(isOn: Bool, finalAlarmTime: AlarmTime) {
        // FIXME: These needs change
        self.isOn = isOn
        self.isMuted = false
        self.finalAlarmTime = finalAlarmTime
        self.snoozeState = .off
        self.departureTime = finalAlarmTime
        self.sleepReminderState = .off
    }
    
    static func firstTimeAlarms(for weekday: Weekday) -> [Alarm] {
        [
            Alarm(isOn: false, finalAlarmTime: AlarmTime(day: weekday.offSet(by: -1), hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: weekday.offSet(by: 0), hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: weekday.offSet(by: 1), hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: weekday.offSet(by: 2), hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: weekday.offSet(by: 3), hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: weekday.offSet(by: 4), hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: weekday.offSet(by: 5), hour: 9, minute: 01)),
        ]
    }
}

enum SnoozeState {
    case off
    case duration(minutes: Int)
}

enum SleepReminderState {
    case off
    case duration(hours: Int = 8)
}

// MARK: - Equatable

extension Alarm: Equatable {
    static func == (lhs: Alarm, rhs: Alarm) -> Bool {
        return lhs.isOn == rhs.isOn &&
        lhs.isMuted == rhs.isMuted &&
        lhs.finalAlarmTime == rhs.finalAlarmTime &&
        lhs.snoozeState == rhs.snoozeState &&
        lhs.departureTime == rhs.departureTime &&
        lhs.sleepReminderState == rhs.sleepReminderState
    }
}

extension SnoozeState: Equatable {}

extension SleepReminderState: Equatable {}

// MARK: - Codable

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

extension Alarm: Codable {}
