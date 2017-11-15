//
//  TimeEngineTests.swift
//  DWMTests
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest
@testable import DWM

class TimeEngineTests: XCTestCase {

    func testFixedNow() {
        let now = date(month: 1, day: 1)
        let timeEngine = TimeEngine(fixedNow: now)
        XCTAssertEqual(timeEngine.now, now)
    }

    func testFixedNowDoesNotChange() {
        let now = date(month: 1, day: 1)
        let timeEngine = TimeEngine(fixedNow: now)
        XCTAssertEqual(timeEngine.now, now)
        XCTAssertEqual(timeEngine.now, now)
    }

    func testFixedNowChanges() {
        let firstNow = date(month: 1, day: 1)!
        let secondNow = date(month: 1, day: 2)!
        let timeEngine = TimeEngine(fixedNow: firstNow)
        timeEngine.now = secondNow
        XCTAssertNotEqual(timeEngine.now, firstNow)
        XCTAssertEqual(timeEngine.now, secondNow)
    }

    func testCurrentPeriodDaily() {
        do {
            let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 1, year: 1))
            let daily = try timeEngine.currentPeriod(for: .daily)
            let formatter = DateFormatter(format: "yyyy/M/dd HH:mm:ss")
            let targetStart = formatter.date(from: "1/1/1 00:00:00")!
            let targetEnd = formatter.date(from: "1/1/2 00:00:00")!
            XCTAssertEqual(daily.start, targetStart)
            XCTAssertEqual(daily.end, targetEnd)
        } catch {
            XCTFail()
        }
    }

    func testCurrentPeriodWeekly() {
        do {
            // November 5, 2017 was a Sunday
            let timeEngine = TimeEngine(fixedNow: date(month: 11, day: 8, year: 2017))
            let weekly = try timeEngine.currentPeriod(for: .weekly)
            let formatter = DateFormatter(format: "yyyy/M/dd HH:mm:ss")
            let targetStart = formatter.date(from: "2017/11/5 00:00:00")!
            let targetEnd = formatter.date(from: "2017/11/12 00:00:00")!
            XCTAssertEqual(weekly.start, targetStart)
            XCTAssertEqual(weekly.end, targetEnd)
        } catch {
            XCTFail()
        }
    }

    func testCurrentPeriodMonthly() {
        do {
            let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 15, year: 1))
            let monthly = try timeEngine.currentPeriod(for: .monthly)
            let formatter = DateFormatter(format: "yyyy/M/dd HH:mm:ss")
            let targetStart = formatter.date(from: "1/1/1 00:00:00")!
            let targetEnd = formatter.date(from: "1/2/1 00:00:00")!
            XCTAssertEqual(monthly.start, targetStart)
            XCTAssertEqual(monthly.end, targetEnd)
        } catch {
            XCTFail()
        }
    }

    func testDateIsInCurrentPeriod() {
        do {
            let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 1))
            let testDate = date(month: 1, day: 1, hour: 10)!
            let dailyResult = try timeEngine.isDate(testDate, inCurrentPeriodfor: .daily)
            let weeklyResult = try timeEngine.isDate(testDate, inCurrentPeriodfor: .weekly)
            let monthlyResult = try timeEngine.isDate(testDate, inCurrentPeriodfor: .monthly)
            XCTAssertTrue(dailyResult)
            XCTAssertTrue(weeklyResult)
            XCTAssertTrue(monthlyResult)
        } catch {
            XCTFail()
        }
    }

    func testDateIsMixedInCurrentPeriod() {
        do {
            // November 5, 2017 was a Sunday
            let fixedNow = date(month: 11, day: 8, year: 2017)!
            let testDate = date(month: 11, day: 9, year: 2017, hour: 3)!
            let timeEngine = TimeEngine(fixedNow: fixedNow)
            let dailyResult = try timeEngine.isDate(testDate, inCurrentPeriodfor: .daily)
            let weeklyResult = try timeEngine.isDate(testDate, inCurrentPeriodfor: .weekly)
            let monthlyResult = try timeEngine.isDate(testDate, inCurrentPeriodfor: .monthly)
            XCTAssertFalse(dailyResult)
            XCTAssertTrue(weeklyResult)
            XCTAssertTrue(monthlyResult)
        } catch {
            XCTFail()
        }
    }

    func testDateIsNotInCurrentPeriod() {
        do {
            // November 5, 2017 was a Sunday
            let timeEngine = TimeEngine(fixedNow: date(month: 11, day: 8, year: 2017))
            let testDate = date(month: 12, day: 1, hour: 1)!
            let dailyResult = try timeEngine.isDate(testDate, inCurrentPeriodfor: .daily)
            let weeklyResult = try timeEngine.isDate(testDate, inCurrentPeriodfor: .weekly)
            let monthlyResult = try timeEngine.isDate(testDate, inCurrentPeriodfor: .monthly)
            XCTAssertFalse(dailyResult)
            XCTAssertFalse(weeklyResult)
            XCTAssertFalse(monthlyResult)
        } catch {
            XCTFail()
        }
    }

    func testDateIsToday() {
        let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 1))
        let testDate = date(month: 1, day: 1, hour: 23)!
        let result = timeEngine.isDateToday(testDate)
        XCTAssertTrue(result)
    }

    func testDateIsNotToday() {
        let timeEngine = TimeEngine(fixedNow: date(month: 1, day: 1))
        let testDate = date(month: 1, day: 2)!
        let result = timeEngine.isDateToday(testDate)
        XCTAssertFalse(result)
    }

    func testResync() {
        let fixed = date(month: 1, day: 1)
        let timeEngine = TimeEngine(fixedNow: fixed)
        XCTAssertEqual(timeEngine.now, fixed)
        timeEngine.resync()
        XCTAssertNotEqual(timeEngine.now, fixed)
    }
}
