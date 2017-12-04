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
    var now: Date { get }

    /// The simulation mode for simulating `now`
    var simulationMode: TimeEngineSimulationMode? { get set }

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

    /// Simulates a day change in a direction.
    /// - parameter forward: Whether the day change should be forward in time.
    func simulateDayChange(forward: Bool)
}

enum TimeEngineError: Swift.Error {
    case internalError
}

/// Mode for simulating time in a time engine
enum TimeEngineSimulationMode {
    /// Simulates a fixed point in time
    case fixed(Date)
    /// Simulates a non-fixed time by offsetting actual now
    case offset(TimeInterval)
}

final class TimeEngine: TimeEngineProtocol {
    let calendar: Calendar
    var now: Date {
        if let mode = simulationMode {
            switch mode {
            case .fixed(let fixedDate): return fixedDate
            case .offset(let offset): return Date().addingTimeInterval(offset)
            }
        } else {
            return Date()
        }
    }

    var simulationMode: TimeEngineSimulationMode?

    init(calendar: Calendar = .current, simulationMode: TimeEngineSimulationMode? = nil) {
        self.calendar = calendar
        self.simulationMode = simulationMode
    }

    convenience init(calendar: Calendar = .current, fixedNow: Date) {
        self.init(calendar: calendar, simulationMode: .fixed(fixedNow))
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

    func simulateDayChange(forward: Bool) {
        let day: TimeInterval = 86_400 * (forward ? 1 : -1)
        if let currentMode = simulationMode {
            switch currentMode {
            case .fixed(let fixedDate):
                simulationMode = .fixed(fixedDate.addingTimeInterval(day))
            case .offset(let currentOffset):
                simulationMode = .offset(currentOffset + day)
            }
        } else {
            simulationMode = .offset(day)
        }
        NotificationCenter.default.post(name: .NSCalendarDayChanged, object: nil)
    }
}
