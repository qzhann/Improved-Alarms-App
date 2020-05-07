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
