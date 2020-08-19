//
//  UserData.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/24/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

var testUserData = UserData(alarmDays: AlarmDay.sampleAlarmDays, isAwakeConfirmed: false, nextAlarmDay: .wednesday)

final class UserData: ObservableObject {
    @PublishedCollection var alarmDays: [AlarmDay]
    var collectionCancellable: AnyCancellable?
    var prefillAlarm = Alarm.default
    var systemClock: SystemClock
    /// The last time `alarms` was reorderd. `mostRecentReorderDate` is usally set to be the start of day when reordering occurs, so that if the app did not launch in a week, it will trigger a reorder once it has reached past the start of day.
    var mostRecentReorderDate: Date
    /// Manages the subscription with `systemClock`'s `alarmTimeUpdate` publisher.
    var alarmTimeUpdateCancellable: AnyCancellable?
    
    // FIXME: This needs to change
    var nextAlarmDay: AlarmDay {
        if let alarm = alarmDays[0].alarm, !alarm.isMuted, !alarm.isAwakeConfirmed {
            return alarmDays[0]
        } else {
            return alarmDays[1]
        }
    }
    
    /// Initializes a `UserData` by specifying alarms, systemClock, and lastUpdateDate.
    /// - Parameters:
    ///   - alarms: An array of `AlarmDay` used by `UserData`.
    ///   - systemClock: The `SystemClock` used by `UserData`. Providing a non-default instance could change the clock speed, useful for testing.
    ///   - mostRecentReorderDate: The start of day of the most recent Date that `alarms` was reorderd.
    init(alarmDays: [AlarmDay], prefillAlarm: Alarm = .default, systemClock: SystemClock = SystemClock(), mostRecentReorderDate: Date = Date()) {
        let sortedAlarmDays = alarmDays.sorted(by: <)
        self.alarmDays = sortedAlarmDays
        self.prefillAlarm = prefillAlarm
        self.systemClock = systemClock
        self.mostRecentReorderDate = mostRecentReorderDate
        // Note that reorder will fire as soon as the subscription is activated
        self.alarmTimeUpdateCancellable = systemClock.alarmTimeUpdate
            .sink { currentTime in
                self.reorderAlarms(using: currentTime)
            }
        // send changes when alarmDays or any of its element changes
        self.collectionCancellable = $alarmDays.sink { self.objectWillChange.send() }
    }
    
    /// Initializes a `UserData` by specifying alarms, the isAwakeConfirmed status for the 0th day, and the alarm that will appear for the next day.
    convenience init(alarmDays: [AlarmDay], isAwakeConfirmed: Bool, nextAlarmDay: Weekday) {
        let initialDate = alarmDays.first(where: { $0.day == nextAlarmDay })!.alarmInterval.start.advancedBy(minutes: -5).date
        self.init(alarmDays: alarmDays, prefillAlarm: Alarm.default, systemClock: SystemClock.nonUpdatingClock(initialDate: initialDate), mostRecentReorderDate: initialDate)
        
        // Rotate the alarm days
        let index = alarmDays.firstIndex(where: { $0.day == Weekday(rawValue: nextAlarmDay.rawValue - 1) })!
        let rotatedDays = alarmDays.leftRotated(degree: index)
        self.alarmDays = rotatedDays
        self.alarmDays[0].alarm?.isAwakeConfirmed = false
    }
    
    // Cleans up memory
    deinit {
        self.alarmTimeUpdateCancellable = nil
    }
    
    /// Updates `alarms` using `currentTime`.
    private func reorderAlarms(using currentTime: AlarmTime) {
        // FIXME:
//        var newAlarms = reorderedAlarms(for: alarms.sorted(by: <), at: currentTime)
//        // If at least a week has passed, or the 0th alarm has changed due to the change of currentTime, perform the update
//        if mostRecentReorderDate.advanced(by: 7.day) < systemClock.currentDate || newAlarms[0].day != alarms[0].day {
//            // Reset all new alarm's isAwakeConfirmed state to true
//            for i in alarms.indices {
//                newAlarms[i].isAwakeConfirmed = true
//            }
//
//            // If the 0th alarm is on and not muted, set its isWakeConfirmed state to false
//            if newAlarms[0].isConfigured && !newAlarms[0].isMuted {
//                newAlarms[0].isAwakeConfirmed = false
//            }
//            // Memorize the last update date as the start of day of now
//            self.mostRecentReorderDate = Calendar.autoupdatingCurrent.startOfDay(for: systemClock.currentDate)
//
//            self.alarms = newAlarms
//        }        
    }
    
//    /// Sets `isAwakeConfirmed` for alarm to true.
//    /// - Parameter alarm: The `Alarm` instance that needs to confirm awake.
//    func confirmAwake(for alarmDay: AlarmDay) {
//        guard let alarmIndex = indexForAlarm(alarm) else { fatalError("Cannot find alarm") }
//        self.alarms[alarmIndex].isAwakeConfirmed = true
//    }
//
//    /// Toggles `isMuted` for alarm.
//    /// - Parameter alarm: The `Alarm` instance that needs to toggle muted state.
//    func toggleMuted(for alarm: Alarm) {
//        guard let alarmIndex = indexForAlarm(alarm) else { fatalError("Cannot find alarm") }
//        self.alarms[alarmIndex].isMuted.toggle()
//    }
//
//    /// Replaces the alarm at the index of `origionalAlarm` with the new alarm
//    func syncAlarm(_ newAlarm: Alarm, origionalAlarm: Alarm) {
//        guard let alarmIndex = indexForAlarm(origionalAlarm) else { fatalError("Cannot find alarm") }
//        self.alarms[alarmIndex].fill(using: newAlarm)
//    }
    
    /// Configures the alarm using the prefill alarm for the specified alarm day.
    /// - Parameter alarmDay: The alarmDay that needs to configure a new alarm.
    func configureAlarm(for alarmDay: AlarmDay) {
        assert(alarmDay.alarm == nil, "Alarm day should not have alarm if it calls for a configure")
        alarmDay.configureAlarm(using: prefillAlarm)
    }
    
    /// Removes the specified alarm. Current implementation sets the specified alarm's `isConfigured` to false.
    /// - Parameter alarmDay: The alarmDay that needs to remove its alarm.
    func removeAlarm(for alarmDay: AlarmDay) {
        // We call removeAlarm on the userData instead of on the alarm day directly so that configure and remove can exhibit symmetrical patterns
        assert(alarmDay.alarm != nil, "Alarm day should have existing alarm if it calls for a remove")
        alarmDay.removeAlarm()
    }
}

// MARK: - Basic behavior protocols

extension UserData: Equatable {
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.alarmDays == rhs.alarmDays &&
            lhs.prefillAlarm == rhs.prefillAlarm &&
            lhs.mostRecentReorderDate == rhs.mostRecentReorderDate
    }
}

extension UserData: Codable {
    enum CodingKeys: String, CodingKey {
        case alarmDays
        case prefillAlarm
        case lastUpdateDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alarmDays, forKey: .alarmDays)
        try container.encode(prefillAlarm, forKey: .prefillAlarm)
        try container.encode(mostRecentReorderDate, forKey: .lastUpdateDate)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let alarmDays = try container.decode([AlarmDay].self, forKey: .alarmDays)
        let prefillAlarm = try container.decode(Alarm.self, forKey: .prefillAlarm)
        let lastUpdateDate = try container.decode(Date.self, forKey: .lastUpdateDate)
        self.init(alarmDays: alarmDays, prefillAlarm: prefillAlarm, mostRecentReorderDate: lastUpdateDate)
    }
}
