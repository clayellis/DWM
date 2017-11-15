//
//  Store.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

/// Defines methods for store, retrieving, and deleting values
protocol SimpleStoreProtocol {
    /// Stores a `value` with an `identifier` for future retrieval
    func store(value: Any, withIdentifier identifier: String)

    /// Returns a value (`Any`) for an `identifier` if it exists
    func retrieveValue(withIdentifier identifier: String) -> Any?

    /// Deletes a value (`Any`) for an `identifier` if it exists
    func deleteValue(withIdentifier identifier: String)
}

extension UserDefaults: SimpleStoreProtocol {
    func store(value: Any, withIdentifier identifier: String) {
        set(value, forKey: identifier)
    }

    func retrieveValue(withIdentifier identifier: String) -> Any? {
        return value(forKey: identifier)
    }

    func deleteValue(withIdentifier identifier: String) {
        removeObject(forKey: identifier)
    }
}
