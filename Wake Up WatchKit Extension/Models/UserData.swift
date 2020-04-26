//
//  UserData.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/24/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation

final class UserData {
    var alarms: [Alarm]
    var nextAlarm: Alarm
    var prefillAlarm: Alarm?
    var userState: UserState = .notRinging
    
    init(alarms: [Alarm]) {
        self.alarms = alarms
        // FIXME: This is wrong
        self.nextAlarm = alarms.first!
    }
}
