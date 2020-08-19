//
//  AlarmDayList.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/25/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct AlarmDayList: View {
    @EnvironmentObject var userData: UserData
    @State var globalRowActionSelection: Int?
    var body: some View {
        List {
            ForEach(userData.alarmDays) { (alarmDay: AlarmDay) in
                
                NavigationLink(destination:
                    AlarmDaySetting()
                        .environmentObject(alarmDay)
                ) {
                    if alarmDay.canPresentAlarmSettings {
                        AlarmDayCard(alarmDay: alarmDay, globalSelection: self.$globalRowActionSelection, tag: self.userData.alarmDays.firstIndex(of: alarmDay)!)
                    } else {
                        AlarmDayCard(alarmDay: alarmDay, globalSelection: self.$globalRowActionSelection, tag: self.userData.alarmDays.firstIndex(of: alarmDay)!)
                        .onTapGesture {}    // prevents navigation
                    }

                }
                .listRowPlatterColor(.clear)
            }
        }
        .navigationBarTitle(Text("Alarms"))
        .listStyle(CarouselListStyle())
    }
}

struct AlarmList_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDayList()
            .environmentObject(testUserData)
    }
}
