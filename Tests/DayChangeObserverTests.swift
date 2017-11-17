//
//  DayChangeObserverTests.swift
//  DWMTests
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest
@testable import DWM

class DayChangeObserverTests: XCTestCase {

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

    var storage: SimpleStoreProtocol!

    override func setUp() {
        super.setUp()
        storage = Store()
    }

    override func tearDown() {
        super.tearDown()
        (storage as! Store).storage = [:]
    }

    // MARK: Internal Store Tests

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

    // MARK: Day Change Observer Tests

    func testObserverSetsLastObservedDateOnBeginObserving() {
        let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 1))
        let observer = DayChangeObserver(storage: storage, timeEngine: timeEngine)
        XCTAssertNil(observer.lastObservedDate)
        observer.startObserving()
        XCTAssertEqual(observer.lastObservedDate, timeEngine.now)
    }

    func testNoChange() {
        let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 1))
        let observer = DayChangeObserver(storage: storage, timeEngine: timeEngine)
        observer.startObserving()
        timeEngine.now = date(month: 1, day: 1, hour: 3)!
        let didChange = observer.checkForChanges()
        XCTAssertFalse(didChange)
    }

    func testChange() {
        let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 1))
        let observer = DayChangeObserver(storage: storage, timeEngine: timeEngine)
        observer.startObserving()
        timeEngine.now = date(month: 1, day: 2)!
        let didChange = observer.checkForChanges()
        XCTAssertTrue(didChange)
    }

    func testObservesChangeOnNotification() {
        let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 1))
        let observer = DayChangeObserver(storage: storage, timeEngine: timeEngine)
        var flag = false
        observer.onChangesObserved = {
            flag = true
        }
        observer.startObserving()
        timeEngine.now = date(month: 1, day: 1, hour: 3)!
        NotificationCenter.default.post(name: NSNotification.Name.NSCalendarDayChanged, object: nil)
        XCTAssertTrue(flag)
    }

    func testResetObserver() {
        let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 1))
        let observer = DayChangeObserver(storage: storage, timeEngine: timeEngine)
        observer.startObserving()
        XCTAssertNotNil(observer.lastObservedDate)
        observer.reset()
        XCTAssertNil(observer.lastObservedDate)
        timeEngine.now = date(month: 1, day: 2)!
        let didChange = observer.checkForChanges()
        XCTAssertFalse(didChange)
    }
}
