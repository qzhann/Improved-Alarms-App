//
//  Alarm.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/24/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

/// Represents an alarm for a day.
struct Alarm: Identifiable {
    var id = UUID()
    /// Indicates whether the alarm exist for a weekday.
    var isConfigured: Bool
    /// Indicates whether the alarm is muted for a weekday.
    var isMuted: Bool
    var isAwakeConfirmed: Bool
    /// Indicates the final alarm time of the alarm. If alarm is off, `finalAlarmTime` indicates the day on which it is set.
    var finalAlarmTime: AlarmTime
    var departureTime: AlarmTime
    var snoozeState: SnoozeState
    var sleepReminderState: SleepReminderState
    
    /// Initializes an alarm.
    init(isConfigured: Bool, isMuted: Bool, isAwakeConfirmed: Bool, finalAlarmTime: AlarmTime, departureTime: AlarmTime, snoozeState: SnoozeState, sleepReminderState: SleepReminderState) {
        self.isConfigured = isConfigured
        self.isMuted = isMuted
        self.isAwakeConfirmed = isAwakeConfirmed
        self.finalAlarmTime = finalAlarmTime
        self.departureTime = departureTime
        self.snoozeState = snoozeState
        self.sleepReminderState = sleepReminderState
    }
    
    /// A convenience initializer for Alarm.
    init(isConfigured: Bool, finalAlarmTime: AlarmTime) {
        self.init(isConfigured: isConfigured, isMuted: false, isAwakeConfirmed: true, finalAlarmTime: finalAlarmTime, departureTime: finalAlarmTime.advancedBy(minutes: 15), snoozeState: .off, sleepReminderState: .off)
    }
    
    /// Indicates the start and end alarm time for the alarm.
    var alarmInterval: (start: AlarmTime, end: AlarmTime) {
        guard isConfigured else { return (finalAlarmTime.startOfDay, finalAlarmTime.startOfDay) }
        
        if isMuted {
            return (finalAlarmTime, finalAlarmTime)
        } else {
            switch snoozeState {
            case .off:
                return (finalAlarmTime, finalAlarmTime)
            case .duration(minutes: let minutes):
                return (finalAlarmTime.advancedBy(minutes: -minutes), finalAlarmTime)
            }
        }
    }
    
    /// Fills the current alarm using the specfied alarm.
    mutating func fill(using alarm: Alarm) {
        self.isMuted = alarm.isMuted
        self.isAwakeConfirmed = alarm.isAwakeConfirmed
        self.finalAlarmTime = AlarmTime(day: self.finalAlarmTime.day, hour: alarm.finalAlarmTime.hour, minute: alarm.finalAlarmTime.minute)
        self.departureTime = AlarmTime(day: self.departureTime.day, hour: alarm.departureTime.hour, minute: alarm.departureTime.minute)
        self.snoozeState = alarm.snoozeState
        self.sleepReminderState = alarm.sleepReminderState
    }
    
    /// Configures the current alarm using the specified alarm.
    mutating func configure(using alarm: Alarm) {
        self.isConfigured = true
        self.fill(using: alarm)
    }
    
    /// A sample array of alarms sorted by `alarmInterval`'s `start` time. Begins with sunday and ending at saturday.
    static let sampleAlarms: [Alarm] = {
        var alarms = [Alarm]()
        for offset in 0 ..< 7 {
            let day = Weekday.sunday.offSet(by: offset)
            var alarm = Alarm(isConfigured: (day == .saturday || day == .sunday) ? false : true, finalAlarmTime: AlarmTime(day: day, hour: 10, minute: 15))
            if day == .wednesday {
                alarm.isMuted = true
            }
            alarms.append(alarm)
        }
        return alarms
    }()
    
    static var `default`: Alarm = {
        Alarm(isConfigured: true, finalAlarmTime: .init(day: .monday, hour: 9, minute: 00))
    }()
}


// MARK: - View model

extension Alarm {
    
    var day: Weekday {
        finalAlarmTime.day
    }
}

// MARK: - Basic behavior protocols

extension Alarm: CustomStringConvertible {
    var description: String {
        return "\(self.day) \(self.finalAlarmTime.timeDescription) isAwakeConfirmed: \(self.isAwakeConfirmed)"
    }
}

extension Alarm: Comparable {
    static func <(lhs: Alarm, rhs: Alarm) -> Bool {
        return lhs.alarmInterval.start < rhs.alarmInterval.start
    }
}

extension Alarm: Equatable {}

extension Alarm: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Alarm: Codable {}
