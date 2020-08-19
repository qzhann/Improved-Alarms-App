//
//  Models+Helpers.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/30/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

// Returns image names for different purposes
extension String {
    static var onAlarm: String { "bell.fill" }
    static var mutedAlarm: String { "bell.slash.fill" }
    static var noAlarm: String { "zzz" }
}

/// Generates an reodered array of alarms using the current time. The current time is guaranteed to be between the 0th alarm and the 1st alarm.
/// - Parameters:
///   - alarms: The array of alarms to update from. `alarms` is expected to be sorted in increasing startTime.
///   - currentTime: The current time represented as an `AlarmTime`.
func reorderedAlarms(for alarms: [Alarm], at currentTime: AlarmTime) -> [Alarm] {
    if let nextAlarmIndex = alarms.firstIndex(where: { $0.alarmInterval.start  > currentTime}) {
        let previousAlarmIndex = (nextAlarmIndex - 1 + alarms.count) % alarms.count
        return alarms.leftRotated(degree: previousAlarmIndex)
    } else { // After saturday time and before sunday time. Previous alarm is Saturday.
        return alarms.leftRotated(degree: -1)
    }
}
