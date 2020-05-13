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
                if alarm.isAwakeConfirmed {
                    NavigationLink(destination: AlarmSetting(alarm: alarm)) {
                        AlarmCard(alarm: alarm)
                    }
                    .listRowPlatterColor(.clear)
                } else {
                    AlarmCard(alarm: alarm)
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
