//
//  NotificationCenter+Helpers.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/27/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation
import Combine

extension Notification.Name {
    /// Indicating that a list row style picker is in active selection.
    static let listRowStylePickersBecomeActive = Notification.Name("list-row-style-pickers-become-active")
    
    /// Indicating that no list row style picker is in active selection.
    static let listRowStylePickersBecomeInactive = Notification.Name("list-row-style-pickers-become-inactive")

}

/// Posts notifications for active and incative states.
class PickerActiveStateNotificationPostingController {
    let activeNotification: Notification
    let inactiveNotification: Notification
    
    @Published var isActive: Bool = false
    
    // sets `isActive` to `false` after `dueInterval` seconds
    var deactivationTimer: Timer?
    var deactivationCancellable: AnyCancellable?
    var dueInterval: TimeInterval
    
    // posts notifications
    var notificationPostingCancellable: AnyCancellable?
    
    init(activeNotification: Notification, inactiveNotification: Notification, deactivateAfter dueInterval: TimeInterval) {
        self.activeNotification = activeNotification
        self.inactiveNotification = inactiveNotification
        self.dueInterval = dueInterval
        self.deactivationCancellable = $isActive.sink { [unowned self] newValue in
            // activate timer only when `isActive` becomes true
            guard newValue == true else { return }
            // invalidate previous timers
            self.deactivationTimer?.invalidate()
            // sets `isActive` to `false` after `dueInterval` seconds
            self.deactivationTimer = Timer.scheduledTimer(withTimeInterval: self.dueInterval, repeats: false, block: { [unowned self] (timer) in
                self.isActive = false
                timer.invalidate()
            })
        }
        self.notificationPostingCancellable = $isActive
            .removeDuplicates()
            .sink { isActive in
                NotificationCenter.default.post(isActive ? activeNotification : inactiveNotification)
            }
    }
    
    /// The controller responsible for publishing active and inactive notifications for pickers.
    static let `default` = PickerActiveStateNotificationPostingController(activeNotification: Notification(name: .listRowStylePickersBecomeActive), inactiveNotification: Notification(name: .listRowStylePickersBecomeInactive), deactivateAfter: 2)
}
