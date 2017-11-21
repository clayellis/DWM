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

    var storage: SimpleStoreProtocol!

    override func setUp() {
        super.setUp()
        storage = Store()
    }

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

