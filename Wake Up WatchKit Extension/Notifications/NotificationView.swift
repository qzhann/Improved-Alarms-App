//
//  NotificationView.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 4/24/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    var body: some View {
        VStack {
            Text("Today's Weather")
                .font(.system(size: 17, weight: .semibold))
            
            HStack(spacing: 19) {
                Text("72°")
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.yellow)
            }
            .font(.system(size: 43, weight: .light))
            
            HStack(spacing: 19) {
                Text("L: 71°")
                Text("H: 75°")
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
