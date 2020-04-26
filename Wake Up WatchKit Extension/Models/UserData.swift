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
        assert(alarms.count >= 2, "alarms should have at least 2 items")
        self.alarms = alarms
        self.nextAlarm = alarms[1]
    }
}

// MARK: - Equatable

extension UserData: Equatable {
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.alarms == rhs.alarms &&
                lhs.nextAlarm == rhs.nextAlarm &&
                lhs.prefillAlarm == rhs.prefillAlarm &&
                lhs.userState == rhs.userState
    }
}

// MARK: - Codable

extension UserData: Codable {
    enum CodingKeys: String, CodingKey {
        case alarms
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(alarms, forKey: .alarms)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let alarms = try container.decode([Alarm].self, forKey: .alarms)
        self.init(alarms: alarms)
    }
}
