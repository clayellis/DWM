//
//  DayChangeObserver.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

/// Defines an observer that watches for day changes
protocol DayChangeObserverProtocol: class {

    /// Starts observing day changes and executes `closure` when changes occur.
    /// - parameter closure: The closure called when changes are observed.
    /// - returns: An `ObservationToken` used to stop observation (see `stopObserving(_:)`)
    func startObserving(using closure: @escaping () -> Void) -> ObservationToken

    /// Stops observing day changes with token.
    /// - parameter token: The `ObservationToken` received when starting observation (see `startObserving(using:)`)
    func stopObserving(_ token: ObservationToken)

    /// Returns `true` if the day has changed since the last check and triggers the observation closure passed in `startObserving`.
    /// Otherwise returns `false`
    func checkForChanges() -> Bool

    /// Resets the observer such that `checkForChanges()` will return `false` even if the day has changed
    func reset()
}

class DayChangeObserver: DayChangeObserverProtocol {
    typealias Observer = () -> Void

    struct Keys {
        static var lastObservedDate = "LastObservedDate"
    }

    let storage: SimpleStoreProtocol
    let timeEngine: TimeEngineProtocol
    private var observers: [ObservationToken: Observer]

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

    private func cleanObservers() {
        observers = observers.filter { !$0.key.isCancelled }
        if observers.isEmpty {
            NotificationCenter.default.removeObserver(self)
        }
    }

    private func stopObserving() {
        for token in observers.keys {
            stopObserving(token)
        }
    }

    // MARK: Protocol

    func startObserving(using closure: @escaping () -> Void) -> ObservationToken {
        cleanObservers()
        if observers.isEmpty {
            NotificationCenter.default.addObserver(self, selector: #selector(changesObserved), name: .NSCalendarDayChanged, object: nil)
        }
        let token = ObservationToken()
        observers[token] = closure
        _ = checkForChanges()
        return token
    }

    func stopObserving(_ token: ObservationToken) {
        token.cancel()
        cleanObservers()
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
        cleanObservers()
        for observer in observers.values {
            observer()
        }
//        }
    }

    func reset() {
        // TODO: Determine if reset should call stopObserving() to reset observation as well
        lastObservedDate = nil
    }
}
