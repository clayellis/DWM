//
//  TimeEngine.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

/// Defines an engine that keeps track of, measures, and compares time
protocol TimeEngineProtocol: class {
    /// Internal `Calendar`
    var calendar: Calendar { get }

    /// Internal present moment in time
    var now: Date { get set }

    /// Returns a `DateInterval` which defines the current period for a `TaskFrenquency`
    ///
    /// Throws if the current period cannot be calculated
    func currentPeriod(for frequency: TaskFrequency) throws -> DateInterval

    /// Returns `true` if the provided `Date` is in the current period for a `TaskFreqency`
    ///
    /// Throws if the current period could not be calculated
    func isDate(_ date: Date, inCurrentPeriodfor frequency: TaskFrequency) throws -> Bool

    /// Returns if the `date` is in the same day as `now`
    func isDateToday(_ date: Date) -> Bool

    /// Resyncs the internal time
    func resync()
}

enum TimeEngineError: Swift.Error {
    case internalError
}

final class TimeEngine: TimeEngineProtocol {
    let calendar: Calendar
    var now: Date {
        get { return fixedNow ?? Date() }
        set { fixedNow = newValue }
    }

    private var fixedNow: Date?

    init(calendar: Calendar = .current, fixedNow: Date? = nil) {
        self.calendar = calendar
        self.fixedNow = fixedNow
    }

    func currentPeriod(for frequency: TaskFrequency) throws -> DateInterval {
        let component: Calendar.Component
        switch frequency {
        case .daily: component = .day
        case .weekly: component = .weekOfYear
        case .monthly: component = .month
        }
        guard var interval = calendar.dateInterval(of: component, for: now) else {
            throw TimeEngineError.internalError
        }
        interval.end.addTimeInterval(-1)
        return interval
    }

    func isDate(_ date: Date, inCurrentPeriodfor frequency: TaskFrequency) throws -> Bool {
        let currentPeriod = try self.currentPeriod(for: frequency)
        return currentPeriod.contains(date)
    }

    func isDateToday(_ date: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: now)
    }

    func resync() {
        fixedNow = nil
    }
}
