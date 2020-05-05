//
//  AlarmList.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/25/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct AlarmList: View {
    @EnvironmentObject var userData: UserData
    var body: some View {
        List {
            ForEach(userData.alarms) { alarm in
                AlarmCard(alarm: alarm)
                .listRowActionButton(action: {}) {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 33, weight: .medium))
                        .foregroundColor(.secondaryTextColor(for: Alarm.sampleAlarms[1], in: testUserData))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .background(Color.gray)
                }
            }
        }
        .navigationBarTitle(Text("Alarms"))
        .listStyle(CarouselListStyle())
    }
}

struct AlarmList_Previews: PreviewProvider {
    static var previews: some View {
        AlarmList()
            .environmentObject(testUserData)
    }
}
