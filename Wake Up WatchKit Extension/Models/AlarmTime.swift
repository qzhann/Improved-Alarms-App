//
//  AlarmTime.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/24/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

/// An encapsulation of time.
struct AlarmTime {
    private var underlyingDateComponents: DateComponents
    
    /// Initializes an `AlarmTime` by specifying day, hour, and minute.
    init(day: Weekday, hour: Int, minute: Int) {
        var components = AlarmTime.baseComponents
        components.weekday = day.rawValue
        components.hour = hour
        components.minute = minute
        // Initializes using the date to ensure that even if hour, minute is beyond normal range, they could be normalized.
        self.init(ofDate: components.date!)
    }
    
    /// Initializes an `AlarmTime` from a `Date`.
    init(ofDate date: Date) {
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.weekday, .hour, .minute], from: date)
        var resultComponents = AlarmTime.baseComponents
        resultComponents.weekday = dateComponents.weekday!
        resultComponents.hour = dateComponents.hour!
        resultComponents.minute = dateComponents.minute!
        self.underlyingDateComponents = resultComponents
    }
    
    /// Returns an `AlarmTime` indicating the start of day of the instance.
    var startOfDay: AlarmTime {
        return AlarmTime(ofDate: Calendar.autoupdatingCurrent.startOfDay(for: underlyingDateComponents.date!))
    }
    
    var endOfDay: AlarmTime {
        return AlarmTime(ofDate: Calendar.autoupdatingCurrent.startOfDay(for: underlyingDateComponents.date!).advanced(by: 24.hour))
    }
    
    /// Returns an  `AlarmTime` advanced by the `hours` hours and `minutes` minutes from the current `AlarmTime` instance.
    func advancedBy(hours: Int = 0, minutes: Int) -> AlarmTime {
        return AlarmTime(ofDate: underlyingDateComponents.date!.advanced(by: hours.hour + minutes.minute))
    }
    
    /// The base date components used to initialize a `Weekday`.
    private static let baseComponents: DateComponents = {
        var components = DateComponents()
        components.calendar = Calendar.autoupdatingCurrent
        components.year = 2020
        components.month = 5
        components.weekOfMonth = 2
        return components
    }()
    
    /// A shared instance of date formatter. Formats `AlarmTime` to display correctly on the interface.
    private static let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: View model

extension AlarmTime {
    
    var day: Weekday {
        Weekday(rawValue: underlyingDateComponents.weekday!)!
    }
    var hour: Int {
        underlyingDateComponents.hour!
    }
    var minute: Int {
        underlyingDateComponents.minute!
    }
    var timeDescription: String {
        AlarmTime.dateFormatter.string(from: underlyingDateComponents.date!)
    }
    var date: Date {
        underlyingDateComponents.date!
    }
    /// Generates an array of alarm time with range [`start`, `end`), each element is `stride` minutes later than the previous element in the array.
    /// - Parameters:
    ///   - start: The start time. `start` will always be included in the array.
    ///   - end: The end time. Indicates the upper asympototic time.
    ///   - stride: number of minutes each element is later than its previous element.
    /// - Returns: An array of alarm time with range  [`start`, `end`). If `end` is smaller than `start` + `stride`, returns empty array.
    private static func alarmTimes(start: AlarmTime, end: AlarmTime, stride strideMinute: Int = 1) -> [AlarmTime] {
        var times = [AlarmTime]()
        for timeInterval in stride(from: start.date.timeIntervalSinceReferenceDate, to: end.date.timeIntervalSinceReferenceDate, by: Double(strideMinute * 60)) {
            let date = Date(timeIntervalSinceReferenceDate: timeInterval)
            let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.weekday, .hour, .minute], from: date)
            let time = AlarmTime(day: Weekday(rawValue: dateComponents.weekday!)!, hour: dateComponents.hour!, minute: dateComponents.minute!)
            times.append(time)
        }
        return times
    }
    
    /// Generates an array of alarm time with range [`self`, `end`), each element is `stride` minutes later than the previous element in the array.
    /// - Parameters:
    ///   - end: The end time. Indicates the upper asympototic time.
    ///   - stride: number of minutes each element is later than its previous element.
    /// - Returns: An array of alarm time with range  [`self```, `end`). If `end` is smaller than `start` + `stride`, returns empty array.
    func alarmTimes(until end: AlarmTime, stride: Int = 1) -> [AlarmTime] {
        return AlarmTime.alarmTimes(start: self, end: end, stride: stride)
    }
    
    static func allDayAlarmTimesFor(_ alarmTime: AlarmTime, stride: Int = 1) -> [AlarmTime] {
        return alarmTimes(start: alarmTime.startOfDay, end: alarmTime.endOfDay, stride: stride)
    }
}

// MARK: - Basic behavior protocols

extension AlarmTime: CustomStringConvertible {
    var description: String {
        self.timeDescription
    }
}

extension AlarmTime: Equatable, Hashable, Codable {}

extension AlarmTime: Comparable {
    static func < (lhs: AlarmTime, rhs: AlarmTime) -> Bool {
        if (lhs.day < rhs.day) {
            return true
        } else if (lhs.day == rhs.day) {
            if (lhs.hour < rhs.hour) {
                return true
            } else if (lhs.hour == rhs.hour) {
                return lhs.minute < rhs.minute
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

extension Int {
    var minute: TimeInterval {
        return TimeInterval(self * 60)
    }
    var hour: TimeInterval {
        return TimeInterval(self.minute * 60)
    }
    var day: TimeInterval {
        return TimeInterval(self.hour * 24)
    }
}
