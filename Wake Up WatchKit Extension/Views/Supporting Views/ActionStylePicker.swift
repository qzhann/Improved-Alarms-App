//
//  ActionStylePicker.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/8/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

struct ActionStylePicker<SelectionValue, LabelContent>: View where SelectionValue: Hashable, SelectionValue: CustomStringConvertible, LabelContent: View {
    let label: LabelContent
    @Binding var pickerSelectionValue: SelectionValue
    let allPickerSelectionValues: [SelectionValue]
    
    // exclusive picker selection managing
    @Binding private var globalExclusivePickerSelection: Int?
    private let managedExclusivePickerSelection: Int
    var isSelected: Bool {
        globalExclusivePickerSelection == managedExclusivePickerSelection
    }
        
    init(label: LabelContent, selection: Binding<SelectionValue>, allSelections: [SelectionValue], globalExclusivePickerSelection: Binding<Int?>, managedExclusivePickerSelection: Int) {
        self.label = label
        self._pickerSelectionValue = selection
        self.allPickerSelectionValues = allSelections
        self._globalExclusivePickerSelection = globalExclusivePickerSelection
        self.managedExclusivePickerSelection = managedExclusivePickerSelection
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                // picker
                Picker(selection: $pickerSelectionValue, label: EmptyView()) {
                    ForEach(allPickerSelectionValues, id: \.hashValue) { selection in
                        HStack {
                            Spacer()
                            Text(selection.description)
                                .font(Font.monospacedDigit(.system(size: 17, weight: .semibold, design: .rounded))())
                                .padding(.trailing, 2)
                        }.tag(selection)
                    }
                }
                // Clips out the default selection border
                .clipShape(RoundedRectangle(cornerRadius: listRowCornerRadius).scale(x: 0.9, y: 0.5, anchor: .center))
                
                // picker label
                label
                    .font(.system(size: 17, weight: .light))
                    .foregroundColor(.white)
//                    .colorMultiply(self.exclusiveSelectionItem.isSelected ? .systemGreen: .white)
                    .padding()
            }
        }
        .frame(height: 44)
        .overlay(
            // Using color multiply to achive animation
            RoundedRectangle(cornerRadius: listRowCornerRadius)
                .stroke(Color.white, lineWidth: 1.5)
                .colorMultiply(self.isSelected ? .systemGreen: .clear)
                .padding(.all, 1)
        )
        .background(
            Group {
                // Using if-else to achieve instant transition
                if self.isSelected {
                    Color.black.cornerRadius(listRowCornerRadius)
                } else {
                    Color.darkBackground.cornerRadius(listRowCornerRadius)
                }
                EmptyView()
            }
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 0, pressing: { (_) in
            withAnimation(.linear(duration: 0.2)) { self.globalExclusivePickerSelection = self.managedExclusivePickerSelection }
        }, perform: {})
            .focusable(true) { (isFocused) in
                print(isFocused)
        }
    }
}

extension ActionStylePicker where LabelContent == Text {
    init(label: String, selection: Binding<SelectionValue>, allSelections: [SelectionValue], globalExclusivePickerSelection: Binding<Int?>, managedExclusivePickerSelection: Int) {
        self.init(label: Text(label), selection: selection, allSelections: allSelections, globalExclusivePickerSelection: globalExclusivePickerSelection, managedExclusivePickerSelection: managedExclusivePickerSelection)
    }
}

struct ActionStylePicker_Preview: View {
    @State var globalPickerSelection: Int?
    @State var selection = AlarmTime(day: .tuesday, hour: 9, minute: 00)
    var allSelections = AlarmTime(day: .tuesday, hour: 0, minute: 00).alarmTimes(until: AlarmTime(day: .tuesday, hour: 24, minute: 01), stride: 15)
    var body: some View {
        VStack {
            Text(selection.timeDescription)
            ActionStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections, globalExclusivePickerSelection: $globalPickerSelection, managedExclusivePickerSelection: 0)
            ActionStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections, globalExclusivePickerSelection: $globalPickerSelection, managedExclusivePickerSelection: 1)
//            ActionStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections)
        }
        
    }
}

struct ActionStylePicker_Previews: PreviewProvider {
    
    static var previews: some View {
        // using a custom preview struct to circumvent the bug in using property wrapper with static properties
        ActionStylePicker_Preview()
    }
}
