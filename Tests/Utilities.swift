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
