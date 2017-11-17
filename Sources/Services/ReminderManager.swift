//
//  ReminderManager.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

/// Defines a manager for `Reminder`s
protocol ReminderManager {
    /// Returns the `Reminder` for a `TaskFrequency` if one exsits
    func reminder(for frequency: TaskFrequency) -> Reminder?

    /// Creates, sets, and returns a `Reminder` for `TaskFrequency.daily`
    ///
    /// Throws if a `Reminder` could not be created from the provided values
    @discardableResult func setDailyReminder(hour: Int, minute: Int) throws -> Reminder

    /// Creates, sets, and returns a `Reminder` for `TaskFrequency.weekly`
    ///
    /// Throws if a `Reminder` could not be created from the provided values
    @discardableResult func setWeeklyReminder(dayOfWeek: Int, hour: Int, minute: Int) throws -> Reminder

    /// Creates, sets, and returns a `Reminder` for `TaskFrequency.monthly`
    ///
    /// Throws if a `Reminder` could not be created from the provided values
    @discardableResult func setMonthlyReminder(weekOfMonth: Int, dayOfWeek: Int, hour: Int, minute: Int) throws -> Reminder

    /// Removes and returns a `Reminder` for a `TaskFrequency` if one exists.
    @discardableResult func removeReminder(for frequency: TaskFrequency) -> Reminder?
}
