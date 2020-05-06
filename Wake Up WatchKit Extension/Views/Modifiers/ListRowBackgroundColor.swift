//
//  ListRowBackgroundColor.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/3/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

extension View {
    /// A replacement for `.listRowPlatterColor(_:)` which allows row actions.
    func listRowBackgroundColor(_ color: Color) -> some View {
        // Using GeometryReader magically prevents cropping at the trailing edge of the card. But why?
        GeometryReader {
            self
                .frame(width: $0.size.width)
                .background(
                    color
                        .frame(width: screenWidth)
                        .cornerRadius(listRowCornerRadius)
            )
        }
        .frame(height: 100)
        .listRowPlatterColor(.clear)
    }
}

struct ListRowBackgroundColor_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            List {
                AlarmCard(alarm: testUserData.alarms[0])
                    .listRowBackgroundColor(.orange)
                AlarmCard(alarm: testUserData.alarms[1])
                    .listRowBackgroundColor(.orange)
            }
            .previewDisplayName("Custom Modifier")
            
            List {
                AlarmCard(alarm: testUserData.alarms[1])
                    .listRowPlatterColor(.orange)
            }
            .previewDisplayName("System Modifier")
        }
        .environmentObject(testUserData)
    }
}
