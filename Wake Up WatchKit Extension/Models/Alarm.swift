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
    enum SnoozeState {
        case off
        case duration(minutes: Int)
    }
    
    enum SleepReminderState {
        case off
        case duration(hours: Int = 8)
    }
        
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
            Alarm(isOn: false, finalAlarmTime: AlarmTime(day: .sunday, hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: .monday, hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: .tuesday, hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: .wednesday, hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: .thursday, hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: .friday, hour: 9, minute: 01)),
            Alarm(isOn: true, finalAlarmTime: AlarmTime(day: .saturday, hour: 9, minute: 01)),
        ]
    }
}
