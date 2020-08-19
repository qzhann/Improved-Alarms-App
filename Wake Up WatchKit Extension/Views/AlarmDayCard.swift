//
//  AlarmDayCard.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/21/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct AlarmDayCard: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var alarmDay: AlarmDay
    
    @Binding var globalSelection: Int?
    let tag: Int
    
    var body: some View {
        Group {
            if alarmDay.canPresentRowActions {
                rowContent
                    .listRowActionButton(globalSelection: $globalSelection, tag: self.tag, action: { self.toggleMuted() }) {
                        Group {
                            // using if-else with transition so that row action fades out when tapped
                            if alarmDay.alarm!.isMuted {
                                RowActionView(alarmDay: alarmDay)
                                    .transition(.opacity)
                                    .animation(.linear(duration: 0.5))
                            } else {
                                RowActionView(alarmDay: alarmDay)
                            }
                        }
                    }
            } else {
                rowContent
            }
        }
        .environmentObject(alarmDay)
    }
    
    var rowContent: some View {
        ZStack(alignment: .topTrailing) {
            // spacing
            HStack {
                // basic card
                VStack(alignment: .leading, spacing: -4) {
                    
                    // top half
                    HStack {
                        Text(alarmDay.day.abbreviation)
                            .foregroundColor(.primaryTextColor(for: alarmDay, in: userData))
                            .font(Font.system(size: 30, weight: .semibold))
                            .padding()
                            .padding(.leading, 3)
                        
                        Spacer()
                        
                        // optional next badge
                        if userData.nextAlarmDay == alarmDay {
                            NextBadge(userData: userData)
                            .foregroundColor(.listRowPlatterColor(for: alarmDay, in: userData))

                        }
                    }
                    .padding(.top, -6)
                    .padding(.trailing, 4)
                    
                    // bottom half
                    HStack(spacing: -4) {
                        if alarmDay.needsToConfirmAwake {
                            // confirm awake button
                            ConfirmAwakeButtonView(userData: userData, alarmDay: alarmDay)
                                .offset(x: 5, y: 0)
                                .onTapGesture {
                                    self.confirmAwake()
                                }
                        } else {
                            // alarm state image
                            Image(systemName: alarmDay.alarmStateImageName)
                                .font(Font.system(size: 26, weight: .medium))
                                .foregroundColor(.alarmStateImageColor(for: alarmDay, in: userData))
                                .padding()
                            
                            // time text
                            Text(alarmDay.timeDescription)
                                .font(Font.system(size: 24, weight: .bold))
                                .padding()
                                .animation(.interactiveSpring(response: 0))
                        }
                    }
                    .frame(height: 40)
                    .foregroundColor(.secondaryTextColor(for: alarmDay, in: userData))
                }
                .padding([.top, .leading], -4)
                Spacer()
            }
        }
        .frame(height: 100)
        .listRowBackgroundColor(.listRowPlatterColor(for: alarmDay, in: userData))
    }
    
    // MARK: Instance methods
    
    func toggleMuted() {
        self.alarmDay.toggleMuted()
    }
    
    func confirmAwake() {
        self.alarmDay.confirmAwake()
    }
}

struct ConfirmAwakeButtonView: View {
    let userData: UserData
    let alarmDay: AlarmDay

    var body: some View {
        HStack {
            Image(systemName: "bell.slash.fill")
                .font(Font.system(size: 22, weight: .medium))
            Text("Confirm awake")
                .font(Font.system(size: 17, weight: .semibold))
                .fixedSize()
        }
        .padding()
        .background(Color.listRowPlatterColor(for: alarmDay, in: userData))
        .cornerRadius(listRowCornerRadius)
        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)
    }
}

struct RowActionView: View {
    let alarmDay: AlarmDay
    
    var body: some View {
        Image(systemName: alarmDay.rowActionImageName)
            .font(.system(size: 33, weight: .medium))
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.rowActionBackgroundColor(for: alarmDay))
    }
}

struct NextBadge: View {
    let userData: UserData
    @EnvironmentObject var alarmDay: AlarmDay
    
    var body: some View {
        Text("NEXT")
            .foregroundColor(.listRowPlatterColor(for: alarmDay, in: userData))
            .font(.system(size: 15, weight: .black, design: .rounded))
            .padding([.leading, .trailing], 5)
            .padding([.top, .bottom], 1.5)
            .background(Color.primaryTextColor(for: alarmDay, in: userData))
            .cornerRadius(4)
            .offset(x: 8)
    }
}

// MARK: - Previews

struct AlarmCard_Preview: View {
    @State var globalSelection: Int?
    
    var body: some View {
        Group {
            ForEach(testUserData.alarmDays) { alarmDay in
                List {
                    AlarmDayCard(alarmDay: alarmDay, globalSelection: self.$globalSelection, tag: testUserData.alarmDays.firstIndex(of: alarmDay)!)
                }
            }
            
            List {
                AlarmDayCard(alarmDay: AlarmDay(day: .tuesday, alarm: Alarm(isConfigured: true, isMuted: true, isAwakeConfirmed: true, finalAlarmTime: .init(day: .thursday, hour: 10, minute: 15), departureTime: .init(day: .thursday, hour: 10, minute: 15), snoozeState: .off, sleepReminderState: .off)), globalSelection: self.$globalSelection, tag: 1)
            }
        }
        .environmentObject(testUserData)
    }
}

struct AlarmDayCard_Previews: PreviewProvider {
    static var previews: some View {
        AlarmCard_Preview()
    }
}
