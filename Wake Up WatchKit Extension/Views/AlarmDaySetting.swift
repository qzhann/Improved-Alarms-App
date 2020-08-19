//
//  AlarmDaySetting.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/22/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI
import Combine

struct AlarmDaySetting: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var alarmDay: AlarmDay
    
    // picker selection managing
    @State private var globalPickerSelection: Int? = nil
    
    let shortLinearAnimation = Animation.linear(duration: 0.2)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 5) {
                    if alarmDay.hasAlarm {
                        Group {
                            ListRowStylePicker(label: "Final Alarm", selection: $alarmDay.finalAlarmTime, allSelections: alarmDay.allDayAlarmTimes, globalSelection: $globalPickerSelection, tag: 0)
                            
                            ListRowStylePicker(label: "Snooze", selection: $alarmDay.snoozeState, allSelections: SnoozeState.allCases, globalSelection: $globalPickerSelection, tag: 1)
                            
                            ListRowStylePicker(label: "Depart at", selection: $alarmDay.departureTime, allSelections: alarmDay.departureTimeSelections, globalSelection: $globalPickerSelection, tag: 2)
                                .simultaneousGesture(   // configures the deapture time selections only on demand
                                    TapGesture()
                                        .onEnded {
                                            self.alarmDay.prepareToConfigureDepartureTime()
                                        }
                                )
                            
                            SleepReminderToggle(isOn: $alarmDay.sleepReminderStateIsOn.animation(.easeInOut))
                            
                            // optional sleep reminder state picker
                            if alarmDay.sleepReminderStateIsOn {
                                ListRowStylePicker(label: "Sleep for", selection: $alarmDay.sleepReminderState, allSelections: SleepReminderState.allCases, globalSelection: $globalPickerSelection, tag: 3)
                                    .transition(.opacity)
                                    .animation(shortLinearAnimation)
                            }
                            
                            
                            RemoveAlarmButton()
                                .padding(.bottom, alarmDay.sleepReminderStateIsOn ? 0 : 44)
                        }
                        
                    } else {
                        ConfigureAlarmButton(userData: userData)
                    }
                }
            }
            
            // optional deactivation button
            if globalPickerSelection != nil {
                Button(action: deactivatePickers) {
                    Text("Done")
                }
                .background(Color.buttonBackground.cornerRadius(.infinity))
                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)
                .background(Color.black.offset(x: 0, y: 20))
                .padding(.bottom, -20)
                .zIndex(1)
                .transition(.opacity)
                .animation(shortLinearAnimation)
            }
            
        }
        
        .navigationBarTitle(alarmDay.day.description)
        .environmentObject(alarmDay)
    }
    
    func deactivatePickers() {
        withAnimation(shortLinearAnimation) {
            self.globalPickerSelection = nil
        }
    }
}

struct ConfigureAlarmButton: View {
    let userData: UserData
    @EnvironmentObject var alarmDay: AlarmDay
    
    var body: some View {
        Text("Configure Alarm")
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.black)
            .fixedSize()
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 44)
            .background(
                Color.systemOrange.cornerRadius(listRowCornerRadius)
            )
            .onTapGesture {
                self.configureAlarm(for: self.alarmDay)
            }
    }
    
    func configureAlarm(for alarmDay: AlarmDay) {
        withAnimation(.linear) { alarmDay.configureAlarm(using: userData.prefillAlarm) }
    }
}

struct RemoveAlarmButton: View {
    @EnvironmentObject var alarmDay: AlarmDay
    @State private var shouldPresentConfirmationSheet = false
    
    var body: some View {
        Text("Remove Alarm")
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.black)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.systemRed.cornerRadius(listRowCornerRadius))
            .padding(.top, 11)
            .onTapGesture { self.shouldPresentConfirmationSheet = true }
            .sheet(isPresented: $shouldPresentConfirmationSheet) {
                self.confirmationSheet
            }
    }
    
    var confirmationSheet: some View {
        VStack {
                Text("Alarm on \(self.alarmDay.day.description) will be removed.")
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 0, maxHeight: .infinity)
        
                Button(action: { self.removeAlarm(for: self.alarmDay) }) {
                    Text("Remove")
                        .foregroundColor(.systemRed)
                }
            }
    }
    
    func removeAlarm(for alarmDay: AlarmDay) {
        alarmDay.removeAlarm()
    }
}

struct SleepReminderToggle: View {
    @Binding var isOn: Bool
    var body: some View {
        ZStack {
            // background
            RoundedRectangle(cornerRadius: listRowCornerRadius)
                .fill(Color.darkBackground)
                .onTapGesture {
                    withAnimation { self.isOn.toggle() }
                }
            
            // label
            HStack {
                Text("Sleep Reminder")
                    .padding()
                Spacer()
            }
            // toggle
            HStack {
                Spacer()
                Toggle(isOn: $isOn) {
                    EmptyView()
                }
                .labelsHidden()
                .padding()
            }
        }
        .frame(height: 44)
    }
}

struct AlarmDaySetting_Preview: View {
    @ObservedObject var testAlarmDay: AlarmDay = testUserData.alarmDays[2]
    var body: some View {
        AlarmDaySetting()
            .environmentObject(testUserData)
            .environmentObject(testAlarmDay)
    }
}

struct AlarmDaySetting_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDaySetting_Preview()
    }
}
