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
                
                // picker label
                label
                    .font(.system(size: 17, weight: .light))
                    .foregroundColor(.white)
                    .colorMultiply(self.exclusiveSelectionItem.isSelected ? .systemGreen: .white)
                    .padding()
            }
        }
        .frame(height: 44)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 0, pressing: { (_) in
            withAnimation(.linear(duration: 0.2)) { self.selectionManager?.changeSelection(self.exclusiveSelectionItem) }
        }, perform: {})
    }
}

extension ActionStylePicker where LabelContent == Text {
    init(label: String, selection: Binding<SelectionValue>, allSelections: [SelectionValue], selectionManager: ExclusiveSelectionManager? = .shared, isSelected: Bool = false) {
        self.init(label: Text(label), selection: selection, allSelections: allSelections, selectionManager: selectionManager, isSelected: isSelected)
    }
}

struct ActionStylePicker_Preview: View {
    @State var selection = AlarmTime(day: .tuesday, hour: 9, minute: 00)
    var allSelections = AlarmTime(day: .tuesday, hour: 0, minute: 00).alarmTimes(until: AlarmTime(day: .tuesday, hour: 12, minute: 01), stride: 15)
    var body: some View {
        VStack {
            ActionStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections, isSelected: true)
            ActionStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections)
            ActionStylePicker(label: "Final Alarm", selection: $selection, allSelections: allSelections)
        }
        
    }
}

struct ActionStylePicker_Previews: PreviewProvider {
    
    static var previews: some View {
        // using a custom preview struct to circumvent the bug in using property wrapper with static properties
        ActionStylePicker_Preview()
    }
}
