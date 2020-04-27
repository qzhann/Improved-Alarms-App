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
        ZStack(alignment: .topTrailing) {
            // spacing
            HStack {
                // basic card
                VStack(alignment: .leading, spacing: -4) {
                    
                    HStack {
                        // day text
                        Text(alarm.day.abbreviation)
                            .foregroundColor(.primaryTextColor(for: alarm, in: userData))
                            .font(Font.system(size: 30, weight: .semibold))
                            .padding()
                        
                        Spacer()
                        
                        // optional next badge
                        if userData.nextAlarm == alarm {
                            NextBadge(for: alarm, in: userData)
                        }
                    }
                    
                    HStack(spacing: -4) {
                        // alarm state image
                        Image(systemName: alarm.stateImageName)
                            .font(Font.system(size: 26, weight: .medium))
                            .padding()
                        
                        // time text
                        Text(alarm.timeDescription)
                            .font(Font.system(size: 24, weight: .bold))
                            .padding()
                    }
                    .foregroundColor(.secondaryTextColor(for: alarm, in: userData))
                }
                .padding([.top, .leading], -4)
                Spacer()
            }
        }
        .frame(height: 100)
        .listRowPlatterColor(.listRowPlatterColor(for: alarm, in: userData))

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
