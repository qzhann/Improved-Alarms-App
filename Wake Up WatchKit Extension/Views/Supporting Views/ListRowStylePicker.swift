//
//  ListRowStylePicker.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/12/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct ListRowStylePicker<SelectionValue, LabelContent>: View where SelectionValue: Hashable, SelectionValue: CustomStringConvertible, LabelContent: View {
    let label: LabelContent
    @State var selectionIndex = 0.0
    @Binding var pickerSelectionValue: SelectionValue
    let allPickerSelectionValues: [SelectionValue]
    
    @ObservedObject var exclusiveSelectionItem: SelectionItem
    weak var selectionManager: ExclusiveSelectionManager?
    
    init(label: LabelContent, selection: Binding<SelectionValue>, allSelections: [SelectionValue], selectionManager: ExclusiveSelectionManager? = .shared, isSelected: Bool = false) {
        self.label = label
        self._pickerSelectionValue = selection
        self.allPickerSelectionValues = allSelections
        self.selectionManager = selectionManager
        self.exclusiveSelectionItem = SelectionItem(isSelected: isSelected)
        selectionManager?.addManagedSelection(exclusiveSelectionItem)
    }
    
    var body: some View {
        HStack {
            // label
            label
                .foregroundColor(.white)
                .colorMultiply(self.exclusiveSelectionItem.isSelected ? .systemGreen: .white)
                .padding(.leading, -4)
                .font(.system(size: 17, weight: .light))
                .offset(x: self.exclusiveSelectionItem.isSelected ? 0.15 : 0, y: self.exclusiveSelectionItem.isSelected ? -0.3 : 0)   // compensates visual offset due to color change
            
            // picker
            Text(allPickerSelectionValues[Int(selectionIndex)].description)
                .font(Font.monospacedDigit(.system(size: 17, weight: .semibold, design: .rounded))())
                .focusable()
                .digitalCrownRotation($selectionIndex, from: 0.0, through: Double(allPickerSelectionValues.count - 1), by: 1, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 44)
        .overlay(
            // Using color multiply to achive animation
            RoundedRectangle(cornerRadius: listRowCornerRadius)
                .stroke(Color.white, lineWidth: 1.5)
                .colorMultiply(self.exclusiveSelectionItem.isSelected ? .systemGreen: .clear)
                .padding(.all, 1)
        )
        .background(
            Group {
                // Using if-else to achieve instant transition
                if self.exclusiveSelectionItem.isSelected {
                    Color.black.cornerRadius(listRowCornerRadius)
                } else {
                    Color.darkBackground.cornerRadius(listRowCornerRadius)
                }
            }
        )
        .onTapGesture {}   // We have to use tap gesture to allow long press gesture to be recognize correctly
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 0, pressing: { (pressing) in
            if pressing {
                withAnimation(.linear(duration: 0.2)) { self.selectionManager?.changeSelection(self.exclusiveSelectionItem) }
            }
        }, perform: {})
    }
}

extension ListRowStylePicker where LabelContent == Text {
    init(label: String, selection: Binding<SelectionValue>, allSelections: [SelectionValue], selectionManager: ExclusiveSelectionManager? = .shared, isSelected: Bool = false) {
        self.init(label: Text(label), selection: selection, allSelections: allSelections, selectionManager: selectionManager, isSelected: isSelected)
    }
}

struct ListRowStylePicker_Preview: View {
    @State var selection = AlarmTime(day: .tuesday, hour: 9, minute: 00)
    var allSelections = AlarmTime(day: .tuesday, hour: 0, minute: 00).alarmTimes(until: AlarmTime(day: .tuesday, hour: 12, minute: 01), stride: 15)
    var body: some View {
        VStack(spacing: 9) {
            ListRowStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections, isSelected: true)
            ListRowStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections)
            ListRowStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections)

        }
    }
}

struct ListRowStylePicker_Previews: PreviewProvider {
    
    static var previews: some View {
        // using a custom preview struct to circumvent the bug in using property wrapper with static properties
        ListRowStylePicker_Preview()
    }
}

