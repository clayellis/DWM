//
//  Utilities.swift
//  DWMTests
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest
@testable import DWM

func date(month: Int, day: Int, year: Int? = nil, hour: Int = 0, calendar: Calendar = .current) -> Date? {
    let year = year ?? calendar.component(.year, from: Date())
    let components = DateComponents(year: year, month: month, day: day, hour: hour)
    return calendar.date(from: components)
}

class DateTests: XCTestCase {
    func testCorrectDate() {
        let components = DateComponents(year: 1993, month: 7, day: 14, hour: 3)
        let calendar = Calendar.current
        let control = calendar.date(from: components)
        let result = date(month: 7, day: 14, year: 1993, hour: 3, calendar: calendar)
        XCTAssertNotNil(control)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, control)
    }

    func testIncorrectDate() {
        let components = DateComponents(year: 1993, month: 7, day: 14, hour: 3)
        let calendar = Calendar.current
        let control = calendar.date(from: components)
        let result = date(month: 11, day: 26, year: 2017, hour: 10, calendar: calendar)
        XCTAssertNotNil(control)
        XCTAssertNotNil(result)
        XCTAssertNotEqual(result, control)
    }
}

class Store: SimpleStoreProtocol {
    var storage: [String: Any?] = [:]

    func store(value: Any, withIdentifier identifier: String) {
        storage[identifier] = value
    }

    func retrieveValue(withIdentifier identifier: String) -> Any? {
        return storage[identifier] ?? nil
    }

    func deleteValue(withIdentifier identifier: String) {
        storage.removeValue(forKey: identifier)
    }
}

class StoreTests: XCTestCase {
    var storage: SimpleStoreProtocol!

    override func setUp() {
        super.setUp()
        storage = Store()
    }

    func testStorageBeginsEmpty() {
        XCTAssert((storage as! Store).storage.count == 0)
    }

    func testStorageStoreValue() {
        let value = 10
        let identifier = "Number"
        storage.store(value: value, withIdentifier: identifier)
        let result = storage.retrieveValue(withIdentifier: identifier) as? Int
        XCTAssertEqual(value, result)
    }

    func testStorageRetrieveMissingValue() {
        storage.store(value: 10, withIdentifier: "Number")
        let result = storage.retrieveValue(withIdentifier: "Not The Same")
        XCTAssertNil(result)
    }

    func testStorageDeleteValue() {
        let value = 10
        let identifier = "Number"
        storage.store(value: value, withIdentifier: identifier)
        let storageResult = storage.retrieveValue(withIdentifier: identifier) as? Int
        XCTAssertEqual(value, storageResult)
        storage.deleteValue(withIdentifier: identifier)
        let deleteResult = storage.retrieveValue(withIdentifier: identifier) as? Int
        XCTAssertNil(deleteResult)
    }
}
