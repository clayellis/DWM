//
//  DayChangeObserver.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

// TODO: Create a simulateByNotification method that will post a NSCalendarDayChanged notification

/// Defines an observer that watches for day changes
protocol DayChangeObserverProtocol: class {
    /// Starts observing day changes with an `identifier` and executes `closure` when changes occur
    /// - parameter identifier: An identifier used when stopping observation (see `stopObserving(identifier:)`)
    /// - parameter closure: The closure called when changes are observed
    func startObserving(identifier: String, _ closure: @escaping () -> ())

    /// Stops observing day changes with an `identifier`
    /// - parameter identifier: The identifier used to start observing (see `startObserving(identifier:_:)`)
    func stopObserving(identifier: String)

    /// Returns `true` if the day has changed since the last check and triggers the observation closure passed in `startObserving`.
    /// Otherwise returns `false`
    func checkForChanges() -> Bool

    /// Resets the observer such that `checkForChanges()` will return `false` even if the day has changed
    func reset()
}

class DayChangeObserver: DayChangeObserverProtocol {
    typealias Observer = () -> ()

    struct Keys {
        static var lastObservedDate = "LastObservedDate"
    }

    let storage: SimpleStoreProtocol
    let timeEngine: TimeEngineProtocol
    private var observers: [String: Observer]

    init(storage: SimpleStoreProtocol = UserDefaults.standard, timeEngine: TimeEngineProtocol) {
        self.storage = storage
        self.timeEngine = timeEngine
        observers = [:]
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

    func startObserving(identifier: String, _ closure: @escaping () -> ()) {
        NotificationCenter.default.addObserver(self, selector: #selector(changesObserved), name: .NSCalendarDayChanged, object: nil)
        observers[identifier] = closure
        _ = checkForChanges()
    }

    func stopObserving(identifier: String) {
        observers.removeValue(forKey: identifier)
        if observers.isEmpty {
            NotificationCenter.default.removeObserver(self)
        }
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
//        DispatchQueue.main.async {
        for observer in observers.values {
            observer()
        }
//        }
    }

    func reset() {
        lastObservedDate = nil
    }

    // MARK: Helpers

    func stopObserving() {
        for identifier in observers.keys {
            stopObserving(identifier: identifier)
        }
    }
}
