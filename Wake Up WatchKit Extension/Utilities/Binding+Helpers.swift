//
//  Binding+Helpers.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/29/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import SwiftUI

/// https://stackoverflow.com/questions/57518852/swiftui-picker-onchange-or-equivalent
extension Binding {
    func onChange(perform handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
        })
    }
}

