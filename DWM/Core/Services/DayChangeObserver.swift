//
//  DayChangeObserver.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

/// Defines an observer that watches for day changes
protocol DayChangeObserverProtocol {
    /// Starts observing day changes
    func startObserving()

    /// Stops observing day changes
    func stopObserving()

    /// Returns `true` if the day has changed since the last check, otherwise returns `false`
    func checkForChanges() -> Bool

    /// Closure which is executed when changes are observed
    var onChangesObserved: (() -> ())? { get set }

    /// Resets the observer such that `checkForChanges()` will return `false` even if the day has changed
    func reset()
}

class DayChangeObserver: DayChangeObserverProtocol {

    struct Keys {
        static var lastObservedDate = "LastObservedDate"
    }

    let storage: SimpleStoreProtocol
    let timeEngine: TimeEngineProtocol

    init(storage: SimpleStoreProtocol = UserDefaults.standard, timeEngine: TimeEngineProtocol) {
        self.storage = storage
        self.timeEngine = timeEngine
    }

    deinit {
        stopObserving()
    }

    // MARK: Helpers

    private(set) var lastObservedDate: Date? {
        get {
            guard let reference = storage.retrieveValue(withIdentifier: Keys.lastObservedDate) as? Int else { return nil }
            return Date(timeIntervalSinceReferenceDate: TimeInterval(reference))
        }

        set {
            if let newValue = newValue {
                let reference = Int(newValue.timeIntervalSinceReferenceDate)
                storage.store(value: reference, withIdentifier: Keys.lastObservedDate)
            } else {
                storage.deleteValue(withIdentifier: Keys.lastObservedDate)
            }
        }
    }

    // MARK: Protocol

    var onChangesObserved: (() -> ())? = nil

    func startObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(changesObserved), name: .NSCalendarDayChanged, object: nil)
        _ = checkForChanges()
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    func checkForChanges() -> Bool {
        defer { lastObservedDate = timeEngine.now }
        guard let lastObservedDate = self.lastObservedDate, !timeEngine.isDateToday(lastObservedDate) else {
            return false
        }
        changesObserved()
        return true
    }

    @objc private func changesObserved() {
        onChangesObserved?()
    }

    func reset() {
        lastObservedDate = nil
    }
}
