//
//  Alarm.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/24/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

enum ScheduleState {
    case ringing, scheduled, scheduledAndMuted, inactive
}

/// Represents an alarm for a day.
struct Alarm: Identifiable {
    var id = UUID()
    var isOn: Bool
    var isMuted: Bool
    var isAwakeConfirmed: Bool
    /// Indicates the final alarm time of the alarm. If alarm is off, `finalAlarmTime` indicates the day on which it is set.
    var finalAlarmTime: AlarmTime
    var departureTime: AlarmTime
    var snoozeState: SnoozeState
    var sleepReminderState: SleepReminderState
    
    /// Indicates the start and end alarm time for the alarm.
    var alarmInterval: (start: AlarmTime, end: AlarmTime) {
        guard isOn else { return (finalAlarmTime.startOfDay, finalAlarmTime.startOfDay) }
        
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
    
    /// Initializes a default alarm.
    /// - Parameters:
    init(isOn: Bool, finalAlarmTime: AlarmTime) {
        // FIXME: These needs change
        self.isOn = isOn
        self.isMuted = false
        self.isAwakeConfirmed = true
        self.finalAlarmTime = finalAlarmTime
        self.snoozeState = .off
        self.departureTime = finalAlarmTime
        self.sleepReminderState = .off
    }
    
    /// A sample array of alarms sorted by `alarmInterval`'s `start` time. Begins with sunday and ending at saturday.
    static let sampleAlarms: [Alarm] = {
        var alarms = [Alarm]()
        for offset in 0 ..< 7 {
            let day = Weekday.sunday.offSet(by: offset)
            var alarm = Alarm(isOn: (day == .saturday || day == .sunday) ? false : true, finalAlarmTime: AlarmTime(day: day, hour: 10, minute: 09))
            if day == .wednesday {
                alarm.isMuted = true
            }
            alarms.append(alarm)
        }
        return alarms
    }()
}

enum SnoozeState {
    case off
    // minutes should be between 0 and 60.
    case duration(minutes: Int)
}

enum SleepReminderState {
    case off
    case duration(hours: Int = 8)
}

// MARK: - View model

extension Alarm {
    
    var day: Weekday {
        finalAlarmTime.day
    }
    
    private var mutedDescription: String { "MUTED" }
    private var offDescription: String {"No Alarm"}
    
    var timeDescription: String {
        if self.isOn {
            if self.isMuted {
                return mutedDescription
            } else {
                return finalAlarmTime.timeDescription
            }
        } else {
            return offDescription
        }
    }
    
    var stateImageName: String {
        if self.isOn {
            if self.isMuted {
                return "bell.slash.fill"
            } else {
                return "bell.fill"
            }
        } else {
            return "zzz"
        }
    }
    
    var rowActionImageName: String {
        guard self.isOn else { fatalError("Off alarms should not display row action image") }

        if isMuted {
            return "bell.fill"
        } else {
            return "bell.slash.fill"
        }
    }
    
    func scheduleState(in userData: UserData) -> ScheduleState {
        if !self.isOn {
            return .inactive
        } else {
            if self == userData.alarms[0] {
                if !self.isAwakeConfirmed {
                    return .ringing
                } else {
                    return .inactive
                }
            } else {
                if self.isMuted {
                    return .scheduledAndMuted
                } else {
                    return .scheduled
                }
            }
        }
    }
}

// MARK: - Basic behavior protocols

extension Alarm: CustomStringConvertible {
    var description: String {
        return "\(self.day) \(self.timeDescription) isAwakeConfirmed: \(self.isAwakeConfirmed)"
    }
}

extension Alarm: Equatable {}

extension SnoozeState: Equatable {}

extension SleepReminderState: Equatable {}

extension Alarm: Comparable {
    static func <(lhs: Alarm, rhs: Alarm) -> Bool {
        return lhs.alarmInterval.start < rhs.alarmInterval.start
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

extension Alarm: Codable {}
