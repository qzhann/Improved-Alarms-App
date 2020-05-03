//
//  SystemClock.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/28/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation
import Combine

class SystemClock {
    /// The current Date of the system.
    var currentDate: Date {
        didSet {
            currentDateDidChange.send(currentDate)
        }
    }
    /// The publisher that `currentDate` will send its values to.
    private var currentDateDidChange: CurrentValueSubject<Date, Never>
    /// Responsible for updating `currentDate`.
    private var timer: Timer?
    /// Returns an `AlarmTime` representing the `currentDate`.
    var currentAlarmTime: AlarmTime {
        return AlarmTime(ofDate: currentDate)
    }
    /// Publish an `AlarmTime` only when a change in `currentDate` changes the corresponding `AlarmTime`.
    var alarmTimeUpdate: AnyPublisher<AlarmTime, Never> {
        currentDateDidChange
            .map { AlarmTime(ofDate: $0) }
            .removeDuplicates { $0.minute == $1.minute && $0.hour == $1.hour && $0.day == $1.day }
            .eraseToAnyPublisher()
    }
    
    /// Refreshes `currentDate` after each `refreshInterval` seconds based on real system time. The default value will refresh `currentDate` each second.
    convenience init(refreshInterval interval: TimeInterval = 1) {
        self.init(incrementInterval: interval, increment: interval)
    }
    
    /// Increments `currentDate` by `increment` seconds after each `incrementInterval` seconds.
    /// - Important: Limit the use of this initializer for testing.
    init(incrementInterval interval: TimeInterval, increment: TimeInterval, initialDate: Date = Date()) {
        self.currentDate = initialDate
        self.currentDateDidChange = CurrentValueSubject<Date, Never>(initialDate)
        self.timer = Timer(timeInterval: interval, repeats: true) { [unowned self] (_) in
            self.currentDate = self.currentDate.advanced(by: increment)
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    static func nonUpdatingClock(initialDate: Date) -> SystemClock {
        return SystemClock(incrementInterval: TimeInterval.infinity, increment: 0, initialDate: initialDate)
    }
    
    // Cleans up memory
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
}
