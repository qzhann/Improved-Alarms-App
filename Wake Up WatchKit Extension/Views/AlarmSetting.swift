//
//  AlarmSetting.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/7/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct AlarmSetting: View {
    @EnvironmentObject var userData: UserData
    var alarm: Alarm
    @State var draftAlarm = Alarm.default
    var allSelections: [AlarmTime]
    
    init(alarm: Alarm) {
        self.allSelections = AlarmTime.allDayAlarmTimesFor(alarm.finalAlarmTime, stride: 15)
        self.alarm = alarm
        self.draftAlarm = self.alarm
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if !alarm.isConfigured {
                    ConfigureAlarmButton(alarm: alarm)
                } else {
                    ActionStylePicker(label: "Final Alarm", selection: $draftAlarm.finalAlarmTime, allSelections: allSelections, isSelected: true)
                        .frame(width: screenWidth + 4)

                    Group {
                        RemoveAlarmButton(alarm: alarm)
                    }
                }
            }
        }
        .onAppear {
            self.draftAlarm = self.alarm
        }
        .onDisappear {
            self.syncAlarm(self.draftAlarm, to: self.userData)
        }
        .navigationBarTitle(alarm.day.description)
    }
    
    // Syncs the draft alarm back to the user data
    func syncAlarm(_ draftAlarm: Alarm, to userData: UserData) {
        userData.syncAlarm(draftAlarm)
    }
}

struct ConfigureAlarmButton: View {
    @EnvironmentObject var userData: UserData
    let alarm: Alarm
    var body: some View {
        Text("Configure Alarm")
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.black)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.systemOrange.cornerRadius(listRowCornerRadius))
            .onTapGesture {
                self.configureAlarm(self.alarm)
            }
    }
    
    func configureAlarm(_ alarm: Alarm) {
        userData.configureAlarm(alarm)
    }
}

struct RemoveAlarmButton: View {
    @EnvironmentObject var userData: UserData
    var alarm: Alarm
    var body: some View {
        Text("Remove Alarm")
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.black)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.systemRed.cornerRadius(listRowCornerRadius))
            .onTapGesture {
                self.removeAlarm(self.alarm)
            }
    }
    
    func removeAlarm(_ alarm: Alarm) {
        
    }
}

struct AlarmSetting_Previews: PreviewProvider {
    @State static var previewAlarm = testUserData.alarms[4]
    static var previews: some View {
        AlarmSetting(alarm: previewAlarm)
    }
}


