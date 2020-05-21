//
//  AlarmSetting.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/7/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI
import Combine

struct AlarmSetting: View {
    @EnvironmentObject var userData: UserData
    @State var draftAlarm = Alarm.default
    // a temporary storage to sync to the State during view's onAppear
    var alarm: Alarm
    
    private var alarmTimeSelections: [AlarmTime]
    private var snoozeStateSelections: [SnoozeState] = allSnoozeStates
    private var sleepReminderStateSelections: [SleepReminderState] = allSleepReminderStates
    
    // picker selection managing
    @State var globalPickerSelection: Int? = 0
    
    @State var crownRotation: Double = 0
    
    init(alarm: Alarm) {
        self.alarm = alarm
        self.alarmTimeSelections = self.alarm.allDayAlarmTimeSelections
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                if !draftAlarm.isConfigured {
                    ConfigureAlarmButton(draftAlarm: $draftAlarm)
                } else {

                    Group {
                        ListRowStylePicker(label: "Final Alarm", selection: $draftAlarm.finalAlarmTime, allSelections: alarmTimeSelections, globalExclusivePickerSelection: $globalPickerSelection, managedExclusivePickerSelection: 0)
                            
                        ListRowStylePicker(label: "Snooze", selection: $draftAlarm.snoozeState, allSelections: snoozeStateSelections, globalExclusivePickerSelection: $globalPickerSelection, managedExclusivePickerSelection: 1)
                        
                        RemoveAlarmButton(draftAlarm: $draftAlarm)
                    }
                }
            }
        }
        .onAppear {
            self.draftAlarm = self.alarm
        }
        .onDisappear {
            self.syncAlarm(self.draftAlarm, origionalAlarm: self.alarm, to: self.userData)
        }
        .navigationBarTitle(draftAlarm.day.description)
    }
    
    // Syncs the draft alarm back to the user data
    func syncAlarm(_ draftAlarm: Alarm, origionalAlarm: Alarm, to userData: UserData) {
        userData.syncAlarm(draftAlarm, origionalAlarm: origionalAlarm)
    }
}

struct ConfigureAlarmButton: View {
    @EnvironmentObject var userData: UserData
    @Binding var draftAlarm: Alarm
    
    var body: some View {
        Text("Configure Alarm")
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.black)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.systemOrange.cornerRadius(listRowCornerRadius))
            .onTapGesture {
                self.configureAlarm(self.draftAlarm)
            }
    }
    
    func configureAlarm(_ alarm: Alarm) {
        userData.configureAlarm(alarm)
        draftAlarm.configure(using: userData.prefillAlarm)
    }
}

struct RemoveAlarmButton: View {
    @EnvironmentObject var userData: UserData
    @Binding var draftAlarm: Alarm

    var body: some View {
        Text("Remove Alarm")
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.black)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.systemRed.cornerRadius(listRowCornerRadius))
            .onTapGesture {
                self.removeAlarm(self.draftAlarm)
            }
    }
    
    func removeAlarm(_ alarm: Alarm) {
        userData.removeAlarm(alarm)
        draftAlarm.isConfigured = false
    }
}

struct AlarmSetting_Previews: PreviewProvider {
    @State static var previewAlarm = testUserData.alarms[5]
    static var previews: some View {
        AlarmSetting(alarm: previewAlarm)
            .environmentObject(testUserData)
    }
}


