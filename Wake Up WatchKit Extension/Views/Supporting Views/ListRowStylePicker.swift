//
//  ListRowStylePicker.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/8/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI
import Combine

struct ListRowStylePicker<PickerSelection, LabelContent, ExclusiveSelection>: View where PickerSelection: Hashable, PickerSelection: CustomStringConvertible, LabelContent: View, ExclusiveSelection: Hashable {
    let label: LabelContent
    @Binding var pickerSelectionValue: PickerSelection
    let allPickerSelectionValues: [PickerSelection]
    
    // exclusive picker selection managing
    @Binding private var globalSelection: ExclusiveSelection?
    private let tag: ExclusiveSelection
    var isSelected: Bool {
        globalSelection == tag
    }
        
    init(label: LabelContent, selection: Binding<PickerSelection>, allSelections: [PickerSelection], globalSelection: Binding<ExclusiveSelection?>, tag: ExclusiveSelection) {
        self.label = label
        self._pickerSelectionValue = selection
        self.allPickerSelectionValues = allSelections
        self._globalSelection = globalSelection
        self.tag = tag
    }
    
    var body: some View {
//        print(Date(), tag, "refreshing")
//        print(tag, allPickerSelectionValues[])
        return ZStack {
            // row background
            Group {
                // Using if-else to achieve instant transition
                if self.isSelected {
                    Color.black.cornerRadius(listRowCornerRadius)
                } else {
                    Color.darkBackground.cornerRadius(listRowCornerRadius)
                }
            }
            
            // row content
            HStack {
                // picker label
                self.label
                    .font(.system(size: 17, weight: .light))
                    .foregroundColor(.white)
                    .colorMultiply(self.isSelected ? .systemGreen: .white)
                    .padding(.leading)
                
                Spacer()
                
                // selection label
                Text(pickerSelectionValue.description)
                    .font(Font.monospacedDigit(.system(size: 17, weight: .semibold, design: .rounded))())
                    .padding(.trailing, 9)
                    .frame(height: 44)
                    .fixedSize()
                    .animation(nil)
            }
            
            if isSelected {
                // underlying picker
//                DigitalCrownPicker(selection: $pickerSelectionValue, allSelections: self.allPickerSelectionValues)
//                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                Picker(selection: $pickerSelectionValue.onChange(perform: { _ in self.setPickerActive(true) }), label: EmptyView()) {
                    ForEach(self.allPickerSelectionValues, id: \.hashValue) { selection in
                        Text(selection.description).tag(selection)
                    }
                }
                // hide the picker to prevent the default picker animation
                .mask(Circle().size(.zero))
            }
            
        }
        .frame(height: 44)
        .overlay(   // selection border
            // Using color multiply to achive animation
            RoundedRectangle(cornerRadius: listRowCornerRadius)
                .stroke(Color.white, lineWidth: 1.5)
                .colorMultiply(self.isSelected ? .systemGreen: .clear)
                .padding(.all, 1)
        )
        .onTapGesture {}    // activates the long press gesture
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 0, pressing: { (_) in
            withAnimation(.linear(duration: 0.2)) {
                // changes the picker selection
                self.globalSelection = self.tag
                // the pickers are now active
                self.setPickerActive(true)
            }
        }, perform: {})
    }
    
    /// Sets the picker active state notification posting controller's `isActive` state.
    func setPickerActive(_ value: Bool) {
        if value == false {
            globalSelection = nil
        }
    }
}

extension ListRowStylePicker where LabelContent == Text {
    init(label: String, selection: Binding<PickerSelection>, allSelections: [PickerSelection], globalSelection: Binding<ExclusiveSelection?>, tag: ExclusiveSelection) {
        self.init(label: Text(label), selection: selection, allSelections: allSelections, globalSelection: globalSelection, tag: tag)
    }
}

struct ActionStylePicker_Preview: View {
    @State private var isPickerActive = false
    @State private var globalPickerSelection: Int?
    @State private var selection = AlarmTime(day: .tuesday, hour: 9, minute: 00)
    @State private var selection2 = AlarmTime(day: .tuesday, hour: 10, minute: 45)
    var allSelections = AlarmTime.allDayAlarmTimes(for: .tuesday, stride: 15)
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                Text("\(isPickerActive ? "Active" : "Not Active")")
                HStack {
                    Text(selection.timeDescription)
                    Text(selection2.timeDescription)
                }
               
                ListRowStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections, globalSelection: $globalPickerSelection, tag: 0)
                ListRowStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections, globalSelection: $globalPickerSelection, tag: 1)
                ListRowStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections, globalSelection: $globalPickerSelection, tag: 2)
                ListRowStylePicker(label: "Final Alarm", selection: $selection2, allSelections: allSelections, globalSelection: $globalPickerSelection, tag: 3)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .listRowStylePickersBecomeActive)) { (_) in
            self.isPickerActive = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .listRowStylePickersBecomeInactive)) { (_) in
            self.isPickerActive = false
        }
    }
}

struct TestPreview: View {
    @State private var selection = 1
    var body: some View {
        ScrollView {
            VStack {
                
                Picker(selection: $selection, label: EmptyView()) {
                    ForEach(0..<5) { number in
                        Text("\(number)")
                    }
                }
                .frame(height: 44)
                
                Button(action: {}) {
                    Text("Button")
                }
                .focusable()
                
                Picker(selection: $selection, label: EmptyView()) {
                    ForEach(0..<5) { number in
                        Text("\(number)")
                    }
                }
                .frame(height: 44)
                
                Picker(selection: $selection, label: EmptyView()) {
                    ForEach(0..<5) { number in
                        Text("\(number)")
                    }
                }
                .frame(height: 44)
            }
        }
    }
}

struct ActionStylePicker_Previews: PreviewProvider {
    
    static var previews: some View {
        // using a custom preview struct to circumvent the bug in using property wrapper with static properties
        ActionStylePicker_Preview()
//        TestPreview()
    }
}
