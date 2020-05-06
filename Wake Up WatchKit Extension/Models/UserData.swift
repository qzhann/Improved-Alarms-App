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

var testUserData = UserData(alarms: Alarm.sampleAlarms, isAwakeConfirmed: false, nextAlarmDay: .friday)

final class UserData: ObservableObject {
    @Published var alarms: [Alarm] {
        didSet {
            self.reorderAlarms(using: systemClock.currentAlarmTime)
        }
    }
    var prefillAlarm: Alarm?
    var systemClock: SystemClock
    /// The last time `alarms` was reorderd. `mostRecentReorderDate` is usally set to be the start of day when reordering occurs, so that if the app did not launch in a week, it will trigger a reorder once it has reached past the start of day.
    var mostRecentReorderDate: Date
    /// Manages the subscription with `systemClock`'s `alarmTimeUpdate` publisher.
    var alarmTimeUpdateCancellable: AnyCancellable?
    
    var nextAlarm: Alarm {
        if alarms[0].isOn && !alarms[0].isMuted && !alarms[0].isAwakeConfirmed {
            return alarms[0]
        } else {
            return alarms[1]
        }
    }
    
    /// Initializes a `UserData` by specifying alarms, systemClock, and lastUpdateDate.
    /// - Parameters:
    ///   - alarms: An array of `Alarm` used by `UserData`.
    ///   - systemClock: The `SystemClock` used by `UserData`. Providing a non-default instance could change the clock speed, useful for testing.
    ///   - mostRecentReorderDate: The start of day of the most recent Date that `alarms` was reorderd.
    init(alarms: [Alarm], systemClock: SystemClock = SystemClock(), mostRecentReorderDate: Date = Date()) {
        assert(alarms.count >= 2, "alarms should have at least 2 items.")
        let sortedAlarms = alarms.sorted(by: <)
        self.alarms = sortedAlarms
        self.systemClock = systemClock
        self.mostRecentReorderDate = mostRecentReorderDate
        // Note that reorder will fire as soon as the subscription is activated
        self.alarmTimeUpdateCancellable = systemClock.alarmTimeUpdate
            .sink { currentTime in
                self.reorderAlarms(using: currentTime)
            }
    }
    
    /// Initializes a `UserData` by specifying alarms, the isAwakeConfirmed status for the 0th day, and the alarm that will appear for the next day.
    convenience init(alarms: [Alarm], isAwakeConfirmed: Bool, nextAlarmDay: Weekday) {
        let initialDate = alarms.first(where: { $0.day == nextAlarmDay })!.alarmInterval.start.advancedBy(minutes: -5).date
        self.init(alarms: alarms, systemClock: SystemClock.nonUpdatingClock(initialDate: initialDate), mostRecentReorderDate: initialDate)
        self.alarms[0].isAwakeConfirmed = isAwakeConfirmed
    }
    
    // Cleans up memory
    deinit {
        self.alarmTimeUpdateCancellable = nil
    }
    
    /// Updates `alarms` using `currentTime`.
    private func reorderAlarms(using currentTime: AlarmTime) {
        var newAlarms = reorderedAlarms(for: alarms.sorted(by: <), at: currentTime)
        // If at least a week has passed, or the 0th alarm has changed due to the change of currentTime, perform the update
        if mostRecentReorderDate.advanced(by: 7.day) < systemClock.currentDate || newAlarms[0].day != alarms[0].day {
            // Reset all new alarm's isAwakeConfirmed state to true
            for i in alarms.indices {
                newAlarms[i].isAwakeConfirmed = true
            }
            
            // If the 0th alarm is on and not muted, set its isWakeConfirmed state to false
            if newAlarms[0].isOn && !newAlarms[0].isMuted {
                newAlarms[0].isAwakeConfirmed = false
            }
            // Memorize the last update date as the start of day of now
            self.mostRecentReorderDate = Calendar.autoupdatingCurrent.startOfDay(for: systemClock.currentDate)
            
            self.alarms = newAlarms
        }        
    }
    
    /// Sets `isAwakeConfirmed` for alarm to true.
    /// - Parameter alarm: The `Alarm` instance that needs to confirm awake.
    func confirmAwake(for alarm: Alarm) {
        guard let alarmIndex = self.alarms.firstIndex(of: alarm) else { fatalError("Cannot find alarm") }
        self.alarms[alarmIndex].isAwakeConfirmed = true
    }
}

// MARK: - Basic behavior protocols

extension UserData: Equatable {
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.alarms == rhs.alarms &&
            lhs.mostRecentReorderDate == rhs.mostRecentReorderDate
    }
}

extension UserData: Codable {
    enum CodingKeys: String, CodingKey {
        case alarms
        case lastUpdateDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alarms, forKey: .alarms)
        try container.encode(mostRecentReorderDate, forKey: .lastUpdateDate)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let alarms = try container.decode([Alarm].self, forKey: .alarms)
        let lastUpdateDate = try container.decode(Date.self, forKey: .lastUpdateDate)
        self.init(alarms: alarms, mostRecentReorderDate: lastUpdateDate)
    }
}
