//
//  DeltaTests.swift
//  DWMTests
//
//  Created by Clay Ellis on 11/21/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest
@testable import DWM

class DeltaTests: XCTestCase {

    func testDelta() {
        let first: [[Int]] = [[0, 1, 2], [3, 4, 5], [8, 9]]
        let second: [[Int]] = [[0, 1, 3], [2, 5, 6]]
        var third = second
        third.append([10])
        let delta = Delta.changes(between: first, and: second)
        // Deleted Rows
        XCTAssertEqual(delta.deletedRows.count, 3)
        XCTAssert(delta.deletedRows.contains(IndexPath(item: 1, section: 1)))
        XCTAssert(delta.deletedRows.contains(IndexPath(item: 0, section: 2)))
        XCTAssert(delta.deletedRows.contains(IndexPath(item: 1, section: 2)))
        // Inserted Rows
        XCTAssertEqual(delta.insertedRows.count, 1)
        XCTAssert(delta.insertedRows.contains(IndexPath(item: 2, section: 1)))
        // Moved Rows
        XCTAssertEqual(delta.movedRows.count, 3)
        XCTAssert(delta.movedRows.contains(where: { $0 == (from: IndexPath(item: 2, section: 0), to: IndexPath(item: 0, section: 1)) }))
        XCTAssert(delta.movedRows.contains(where: { $0 == (from: IndexPath(item: 0, section: 1), to: IndexPath(item: 2, section: 0)) }))
        XCTAssert(delta.movedRows.contains(where: { $0 == (from: IndexPath(item: 2, section: 1), to: IndexPath(item: 1, section: 1)) }))
        // Inserted Sections
        XCTAssertEqual(delta.insertedSections.count, 0)
        // Deleted Sections
        XCTAssertEqual(delta.deletedSections.count, 1)
        XCTAssert(delta.deletedSections.contains(IndexSet(integer: 2)))
        let secondDelta = Delta.changes(between: second, and: third)
        XCTAssertEqual(secondDelta.insertedSections.count, 1)
        XCTAssert(secondDelta.insertedSections.contains(IndexSet(integer: 2)))
    }

}
