//
//  SystemTime.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/28/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation
import Combine

class SystemTime {
    @Published private var currentDate: Date
    /// Responsible for updating `currentDate`.
    private var timer: Timer?
    /// Publish an `AlarmTime` only when a change in `currentDate` changes the corresponding `AlarmTime`.
    var currentAlarmTime: AnyPublisher<AlarmTime, Never> {
        $currentDate
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
    init(incrementInterval interval: TimeInterval, increment: TimeInterval) {
        self.currentDate = Date()
        self.timer = Timer(timeInterval: interval, repeats: true) { (_) in
            self.currentDate = self.currentDate.advanced(by: increment)
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    // Cleans up memory
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
}
