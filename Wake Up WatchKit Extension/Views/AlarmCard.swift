//
//  AlarmCard.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/26/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct AlarmCard: View {
    @EnvironmentObject var userData: UserData
    var alarm: Alarm
    
    var body: some View {
        Group {
            if alarm.isOn && alarm.isAwakeConfirmed {
                rowContent
                .listRowActionButton(action: { self.toggleMuted(for: self.alarm) }) {
                    Group {
                        if alarm.isMuted {
                            RowActionView(alarm: alarm)
                                .transition(.opacity)
                                .animation(.linear(duration: 15))
                                // using if-else with transition here so that the row action disappears when tapped instead of flickers to the new value
                        } else {
                            RowActionView(alarm: alarm)
                        }
                        
                    }
                }
            } else {
                rowContent
            }
        }
        .padding(0)
    }
    
    var rowContent: some View {
        ZStack(alignment: .topTrailing) {
            // spacing
            HStack {
                // basic card
                VStack(alignment: .leading, spacing: -4) {
                    
                    // top half of the card
                    HStack {
                        // day text
                        Text(alarm.day.abbreviation)
                            .foregroundColor(.primaryTextColor(for: alarm, in: userData))
                            .font(Font.system(size: 30, weight: .semibold))
                            .padding()
                            .padding(.leading, 3)
                        
                        Spacer()
                        
                        // optional next badge
                        if userData.nextAlarm == alarm {
                            NextBadge(for: alarm, in: userData)
                        }
                    }
                    .padding(.top, -6)
                    .padding(.trailing, 4)
                    
                    // bottom half of the card
                    HStack(spacing: -4) {
                        if alarm.isAwakeConfirmed {
                            // alarm state image
                            Image(systemName: alarm.stateImageName)
                                .font(Font.system(size: 26, weight: .medium))
                                .foregroundColor(alarm == userData.alarms[0] && !alarm.isMuted ? .systemOrange: .secondaryTextColor(for: alarm, in: userData))
                                .padding()
                            
                            // time text
                            Text(alarm.timeDescription)
                                .font(Font.system(size: 24, weight: .bold))
                                .padding()
                                .animation(.interactiveSpring(response: 0))
                        } else {
                            // confirm awake button
                            ConfirmAwakeButton(alarm: alarm, userData: userData)
                                .offset(x: 5, y: 0)
                                .onTapGesture {
                                    self.confirmAwake(for: self.alarm)
                                }
                        }
                        
                    }
                    .frame(height: 40)
                    .foregroundColor(.secondaryTextColor(for: alarm, in: userData))
                }
                .padding([.top, .leading], -4)
                Spacer()
            }
        }
        .frame(height: 100)
        .listRowBackgroundColor(.listRowPlatterColor(for: alarm, in: userData))
    }
    
    func confirmAwake(for alarm: Alarm) {
        self.userData.confirmAwake(for: alarm)
    }
    
    func toggleMuted(for alarm: Alarm) {
        self.userData.toggleMuted(for: alarm)
    }
}

struct NextBadge: View {
    let alarm: Alarm
    let userData: UserData
    
    init(for alarm: Alarm, in userData: UserData) {
        self.alarm = alarm
        self.userData = userData
    }
    
    var body: some View {
        Text("NEXT")
            .foregroundColor(.listRowPlatterColor(for: alarm, in: userData))
            .font(.system(size: 15, weight: .black, design: .rounded))
            .padding([.leading, .trailing], 5)
            .padding([.top, .bottom], 1.5)
            .background(Color.primaryTextColor(for: alarm, in: userData))
            .cornerRadius(4)
            .offset(x: 8)
    }
}

struct ConfirmAwakeButton: View {
    let alarm: Alarm
    let userData: UserData
    
    var body: some View {
        HStack {
            Image(systemName: "bell.slash.fill")
                .font(Font.system(size: 22, weight: .medium))
            Text("Confirm awake")
                .font(Font.system(size: 17, weight: .semibold))
                .fixedSize()
        }
        .padding()
        .background(Color.listRowPlatterColor(for: alarm, in: userData))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)
    }
}

struct RowActionView: View {
    let alarm: Alarm
    var body: some View {
        Image(systemName: alarm.rowActionImageName)
            .transition(.opacity)
            .animation(.easeInOut(duration: 4))
            
            .font(.system(size: 33, weight: .medium))
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.rowActionBackgroundColor(for: alarm))
            .transition(.opacity)
            
            .animation(.easeInOut(duration: 4))
    }
}

struct AlarmCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(testUserData.alarms) {alarm in
                List {
                    AlarmCard(alarm: alarm)
                }
            }
        }
        .environmentObject(testUserData)
    }
}
