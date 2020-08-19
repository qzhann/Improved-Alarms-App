//
//  AlarmDay.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/20/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation
import Combine

/// Represents a day that contains a possible alarm.
final class AlarmDay: Identifiable, ObservableObject {
    let id = UUID()
    let day: Weekday
    var objectWillChange = ObservableObjectPublisher()
    @Published var alarm: Alarm?
    
    /// Initializes a `AlarmDay` for the specified weekday and using the specified alarm.
    init(day: Weekday, alarm: Alarm?) {
        self.day = day
        self.alarm = alarm
    }
    
    /// Indicates the start and end alarm time for the alarm.
    var alarmInterval: (start: AlarmTime, end: AlarmTime) {
        // return the start of day if alarm does not exist
        guard let alarm = self.alarm else { return (AlarmTime.startOfDay(day: day), AlarmTime.startOfDay(day: day)) }
        
        if alarm.isMuted {
            return (alarm.finalAlarmTime, alarm.finalAlarmTime)
        } else {
            switch alarm.snoozeState {
            case .off:
                return (alarm.finalAlarmTime, alarm.finalAlarmTime)
            case .duration(minutes: let minutes):
                return (alarm.finalAlarmTime.advancedBy(minutes: -minutes), alarm.finalAlarmTime)
            }
        }
    }
    
    /// Confirms awake for the current alarm day.
    func confirmAwake() {
        self.alarm?.isAwakeConfirmed = true
        self.objectWillChange.send()
    }
    
    /// Toggles isMuted state on the current day's alarm.
    func toggleMuted() {
        self.alarm?.isMuted.toggle()
        self.objectWillChange.send()
    }
    
    /// Configures current day's alarm using the specified new alarm.
    func configureAlarm(using newAlarm: Alarm) {
        self.alarm = newAlarm
        self.objectWillChange.send()
    }
    
    /// Removes current day's alarm.
    func removeAlarm() {
        self.alarm = nil
        self.objectWillChange.send()
    }
    
    /// Does some preparation work before the user configures the depature time.
    func prepareToConfigureDepartureTime() {
        // calculate depature time selections
        self.departureTimeSelections = self.finalAlarmTime.alarmTimesUntilEndOfDay(stride: 15)
        self.objectWillChange.send()
    }
    
    /// An array of alarm times starting from the current alarm day's start of day to end of day.
    lazy var allDayAlarmTimes: [AlarmTime] = AlarmTime.allDayAlarmTimes(for: day, stride: 15)

    /// An array of alarm times the depature time could select from. Default to all day alarm times.
    lazy var departureTimeSelections: [AlarmTime] = AlarmTime.allDayAlarmTimes(for: day, stride: 15)
    
    /// A sample array of alarm days. Begins with sunday and ending with saturday.
    static let sampleAlarmDays: [AlarmDay] = {
        var alarmDays = [AlarmDay]()
        for day in Weekday.allCases {
            if day == .sunday || day == .saturday {
                alarmDays.append(.init(day: day, alarm: nil))
            } else if day == .wednesday {
                var alarm = Alarm(isConfigured: true, finalAlarmTime: AlarmTime(day:day, hour: 10, minute: 15))
                alarm.isMuted = true
                alarmDays.append(.init(day: day, alarm: alarm))
            } else {
                let alarm = Alarm(isConfigured: true, finalAlarmTime: AlarmTime(day:day, hour: 10, minute: 15))
                alarmDays.append(.init(day: day, alarm: alarm))
            }
        }
        return alarmDays
    }()
    
    /// A default instance of alarm days for quick initialization.
    static let `default`: AlarmDay = {
        AlarmDay(day: .monday, alarm: .default)
    }()
    
}

// MARK: - View Model

extension AlarmDay {
    private var mutedDescription: String { "MUTED" }
    private var offDescription: String { "No Alarm" }

    
    /// Indicates whether the current alarm day has an existing alarm.
    var hasAlarm: Bool {
        return alarm != nil
    }
    
    /// Indicates whether the current alarm day can present the settings view.
    var canPresentAlarmSettings: Bool {
        // can present unless alarm exists and is not awake confirmed
        return !(hasAlarm && alarm!.isAwakeConfirmed == false)
    }
    
    /// Indicates whether the current alarm day can present row actions.
    var canPresentRowActions: Bool {
        return hasAlarm && alarm!.isAwakeConfirmed
    }
    
    /// Indicates whether the current alarm day needs to confirm awake.
    var needsToConfirmAwake: Bool {
        return hasAlarm && !alarm!.isMuted && !alarm!.isAwakeConfirmed
    }
    
    /// Indicates whether the current alarm day has passed. Either it is before the current time, or that it is before the current time but still needs awake confirmation.
    func hasPassed(in userData: UserData) -> Bool {
        // FIXME: This needs to change
        self == userData.alarmDays[0]
    }
        
    /// Returns the schedule state of the current alarm day in the specified user data instance.
    func alarmScheduleState(in userData: UserData) -> ScheduleState {
        guard let alarm = self.alarm else { return .noAlarm }
        
        if self.hasPassed(in: userData) {   // past alarm day
            
            if alarm.isMuted {
                return .pastMuted
            } else {
                if alarm.isAwakeConfirmed {
                    return .pastActive
                } else {
                    return .ringing
                }
            }
            
        } else {    // future alarm day
            if alarm.isMuted {
                return .futureMuted
            } else {
                return .futureActive
            }
        }
    }
    
    /// Returns the alarm state image name for the current alarm day.
    var alarmStateImageName: String {
        if let alarm = self.alarm {
            if alarm.isMuted {
                return .mutedAlarm
            } else {
                return .onAlarm
            }
        } else {
            return .noAlarm
        }
    }
    
    /// Returns the row action image name for the current alarm day.
    var rowActionImageName: String {
        guard let alarm = self.alarm else { return "" }

        if alarm.isMuted {
            return .onAlarm
        } else {
            return .mutedAlarm
        }
    }
    
    /// Returns the alarm time description for the current alarm day.
    var timeDescription: String {
        guard let alarm = self.alarm else { return offDescription }
        
        if alarm.isMuted {
            return mutedDescription
        } else {
            return alarm.finalAlarmTime.timeDescription
        }
    }
    
    /// Convenience getter and setter for the final alarm time.
    /// - This crashes if the current alarm day does not already have an alarm.
    var finalAlarmTime: AlarmTime {
        get {
            guard self.hasAlarm else { return .default }
            return self.alarm!.finalAlarmTime
        }
        set {
            guard self.hasAlarm else { fatalError("Setting final alarm time requires that alarm day has the alarm") }
            self.alarm?.finalAlarmTime = newValue
            // updates departure time if necessary
            if self.alarm!.departureTime < self.alarm!.finalAlarmTime {
                self.alarm?.departureTime = newValue
            }
            self.objectWillChange.send()
        }
    }
    
    /// Convenience getter and setter for the snooze state.
    /// - This crashes if the current alarm day does not already have an alarm.
    var snoozeState: SnoozeState {
        get {
            guard self.hasAlarm else { return .off }
            return self.alarm!.snoozeState
        }
        set {
            guard self.hasAlarm else { fatalError("Setting snooze state requires that alarm day has the alarm") }
            self.alarm?.snoozeState = newValue
            self.objectWillChange.send()
        }
    }
    
    /// Convenience getter and setter for the departure time.
    /// - This crashes if the current alarm day does not already have an alarm.
    var departureTime: AlarmTime {
        get {
            guard self.hasAlarm else { return .default }
            return self.alarm!.departureTime
        }
        set {
            guard self.hasAlarm else { fatalError("Setting depature time requires that alarm day has the alarm") }
            self.alarm?.departureTime = newValue
            self.objectWillChange.send()
        }
    }
    
    /// Convenience getter and setter for the sleep reminder state.
    /// - This crashes if the current alarm day does not already have an alarm.
    var sleepReminderState: SleepReminderState {
        get {
            guard self.hasAlarm else { return .off }
            return self.alarm!.sleepReminderState
        }
        set {
            guard self.hasAlarm else { fatalError("Setting sleep reminder state time requires that alarm day has the alarm") }
            self.alarm?.sleepReminderState = newValue
            self.objectWillChange.send()
        }
    }
    
    /// Convenience getter and setter to turn on or switch off sleep reminder state.
    /// - This crashes if the current alarm day does not already have an alarm.
    var sleepReminderStateIsOn: Bool {
        get {
            guard self.hasAlarm else { return false }
            return self.alarm!.sleepReminderState != .off
        }
        set {
            guard self.hasAlarm else { fatalError("Setting sleep reminder state is on time requires that alarm day has the alarm") }
            let newSleepReminderState: SleepReminderState = newValue ? .duration(hours: 8) : .off
            self.alarm?.sleepReminderState = newSleepReminderState
            self.objectWillChange.send()
        }
    }
}

// MARK: - Basic behavior protocols

extension AlarmDay: Codable {
    enum CodingKeys: String, CodingKey {
        case day
        case alarm
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(day, forKey: .day)
        try container.encode(alarm, forKey: .alarm)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let day = try container.decode(Weekday.self, forKey: .day)
        let alarm = try container.decodeIfPresent(Alarm.self, forKey: .alarm)
        self.init(day: day, alarm: alarm)
    }
}

extension AlarmDay: Equatable, Comparable {
    static func == (lhs: AlarmDay, rhs: AlarmDay) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: AlarmDay, rhs: AlarmDay) -> Bool {
        return lhs.alarmInterval.start < rhs.alarmInterval.start
    }
}

extension AlarmDay: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - String extension
