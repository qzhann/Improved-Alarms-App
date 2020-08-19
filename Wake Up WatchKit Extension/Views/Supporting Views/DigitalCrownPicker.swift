//
//  DigitalCrownPicker.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/30/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

/// A picker that allows selection of a value from a range of values using the digital crown. Greatly improves picker performance on watchOS.
struct DigitalCrownPicker<PickerSelection>: View where PickerSelection: Hashable, PickerSelection: CustomStringConvertible {
    @State private var crownSelectionValue = 0.0
    @Binding var selection: PickerSelection
    @State private var allSelections: [PickerSelection] = []
    var tempSelection: [PickerSelection]
    
    init(selection: Binding<PickerSelection>, allSelections: [PickerSelection]) {
        self._selection = selection
        self.tempSelection = allSelections
    }
    var body: some View {
        Text(selection.description)
            .focusable()
            .digitalCrownRotation($crownSelectionValue.onChange(perform: { newValue in
                self.selection = self.allSelections[Int(self.crownSelectionValue.rounded())]
            }), from: 0, through: Double(allSelections.count - 1), by: 1, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
            .onAppear {
                self.allSelections = self.tempSelection
                self.crownSelectionValue = Double(self.allSelections.firstIndex(of: self.selection) ?? 0)
            }
    }
}

struct TestPicker_Preview: View {
    @State private var selection = AlarmTime(day: .tuesday, hour: 3, minute: 15)
    var allSelections = AlarmTime.allDayAlarmTimes(for: .tuesday, stride: 15)
    var body: some View {
        DigitalCrownPicker(selection: $selection, allSelections: allSelections)
    }
}

struct TestPicker_Previews: PreviewProvider {
    static var previews: some View {
        TestPicker_Preview()
    }
}
