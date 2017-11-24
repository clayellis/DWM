//
//  RecordManagerTests.swift
//  DWMTests
//
//  Created by Clay Ellis on 11/13/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest
@testable import DWM

class RecordManagerTests: XCTestCase {

    let timeEngine = TimeEngine()
    var recordDataStore: CoreDataStore<TaskCompletionRecordData>!
    var recordManager: RecordManagerProtocol!

    override func setUp() {
        super.setUp()
        let storeURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Test.sqlite")
        let stack = try! CoreDataStack(modelLocation: .bundles(Bundle.allBundles),
                                       storeLocation: .url(storeURL))
        recordDataStore = CoreDataStore(coreDataStack: stack)
        recordManager = RecordManager(timeEngine: timeEngine, recordDataStore: recordDataStore)
    }

    override func tearDown() {
        super.tearDown()
        try? recordDataStore.deleteAll()
        timeEngine.simulationMode = nil
    }

    func testTimeEngineBeginsUnfixed() {
        let first = timeEngine.now
        sleep(0)
        let second = timeEngine.now
        XCTAssertNotEqual(first, second)
    }

    func testDataStoreBeginsEmpty() {
        do {
            let result = try recordDataStore.retrieveAll()
            XCTAssertTrue(result.isEmpty)
        } catch {
            XCTFail()
        }
    }

    func testRecordManagerBeginsEmpty() {
        XCTAssert(recordManager.records.isEmpty)
    }

    // TODO: Test object equality

    func testTaskCompletionRecord() {
        let id = UUID()
        let taskID = UUID()
        let timestamp = Date()
        let record = TaskCompletionRecord(id: id, taskID: taskID, timestamp: timestamp)
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.taskID, taskID)
        XCTAssertEqual(record.timestamp, timestamp)
    }

    func testTaskCompletionRecordFromData() {
        do {
            let recordData = TaskCompletionRecordData(context: recordDataStore.context)
            recordData.id = UUID()
            recordData.taskID = UUID()
            recordData.timestamp = NSDate()
            let record = try TaskCompletionRecord(from: recordData)
            XCTAssertEqual(record.id, recordData.id)
            XCTAssertEqual(record.taskID, recordData.taskID)
            XCTAssertEqual(record.timestamp, recordData.timestamp as Date?)
        } catch {
            XCTFail()
        }
    }

    func testTaskCompletionRecordData() {
        let record = TaskCompletionRecord(taskID: UUID(), timestamp: Date())
        let recordData = TaskCompletionRecordData(from: record, in: recordDataStore.context)
        XCTAssertEqual(record.id, recordData.id)
        XCTAssertEqual(record.taskID, recordData.taskID)
        XCTAssertEqual(record.timestamp, recordData.timestamp as Date?)
    }

    func testTaskCompletionRecordDataCoreDataStorable() {
        let record = TaskCompletionRecord(taskID: UUID(), timestamp: Date())
        let recordData = record.prepareForStorage(in: recordDataStore.context)
        XCTAssertEqual(record.id, recordData.id)
        XCTAssertEqual(record.taskID, recordData.taskID)
        XCTAssertEqual(record.timestamp, recordData.timestamp as Date?)
    }

    func testCreateRetrieveRecord() {
        do {
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1)!)
            let task = Task(title: "Hello", frequency: .daily)
            try recordManager.createCompletionRecord(for: task)
            let records = recordManager.records
            XCTAssert(records.count == 1)
            guard let record = records.first else {
                XCTFail()
                return
            }
            XCTAssertEqual(record.taskID, task.id)
            XCTAssertEqual(record.timestamp, timeEngine.now)
        } catch {
            XCTFail()
        }
    }

    func testRetrieveRecordsByPeriod() {
        do {
            let taskOne = Task(title: "One", frequency: .daily)
            let taskTwo = Task(title: "Two", frequency: .weekly)
            let taskOneCount = 3
            let taskTwoCount = 2
            for _ in 0 ..< taskOneCount {
                try recordManager.createCompletionRecord(for: taskOne)
            }

            for _ in 0 ..< taskTwoCount {
                try recordManager.createCompletionRecord(for: taskTwo)
            }

            let taskOneRecords = recordManager.records(for: taskOne)
            let taskTwoRecords = recordManager.records(for: taskTwo)

            XCTAssert(taskOneRecords.count == taskOneCount)
            XCTAssert(taskTwoRecords.count == taskTwoCount)

            XCTAssert(taskOneRecords.reduce(true) { $0 && $1.taskID == taskOne.id })
            XCTAssert(taskTwoRecords.reduce(true) { $0 && $1.taskID == taskTwo.id })
        } catch {
            XCTFail()
        }
    }

    func testLatestRecordShouldExist() {
        do {
            let task = Task(title: "Hello", frequency: .daily)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1, hour: 2)!)
            let firstRecord = try recordManager.createCompletionRecord(for: task)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1, hour: 10)!)
            let secondRecord = try recordManager.createCompletionRecord(for: task)
            guard let latest = recordManager.latestRecord(for: task) else {
                XCTFail("latest record should exist")
                return
            }
            XCTAssertNotEqual(firstRecord, secondRecord)
            XCTAssertNotEqual(latest, firstRecord)
            XCTAssertEqual(latest, secondRecord)
        } catch {
            XCTFail()
        }
    }

    func testLatestRecordShouldNotExist() {
        let task = Task(title: "Hello", frequency: .daily)
        let latest = recordManager.latestRecord(for: task)
        XCTAssertNil(latest)
    }

    func testLatestRecordInCurrentPeriodExists() {
        do {
            let task = Task(title: "Hello", frequency: .daily)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1, hour: 2)!)
            try recordManager.createCompletionRecord(for: task)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1, hour: 10)!)
            try recordManager.createCompletionRecord(for: task)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 2, hour: 5)!)
            let thirdRecord = try recordManager.createCompletionRecord(for: task)
            guard let latest = recordManager.latestRecordInCurrentPeriod(for: task) else {
                XCTFail("latest record should exist")
                return
            }
            XCTAssertEqual(latest, thirdRecord)
        } catch {
            XCTFail()
        }
    }

    func testLatestRecordInCurrentPeriodDoesNotExist() {
        do {
            let task = Task(title: "Hello", frequency: .daily)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1, hour: 2)!)
            try recordManager.createCompletionRecord(for: task)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1, hour: 10)!)
            try recordManager.createCompletionRecord(for: task)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 2, hour: 5)!)
            let latest = recordManager.latestRecordInCurrentPeriod(for: task)
            XCTAssertNil(latest)
        } catch {
            XCTFail()
        }
    }

    func testRemoveRecordExists() {
        do {
            let task = Task(title: "Hello", frequency: .daily)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1)!)
            let record = try recordManager.createCompletionRecord(for: task)
            XCTAssert(recordManager.records.count == 1)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1, hour: 10)!)
            guard let removed = recordManager.removeCompletionRecord(for: task) else {
                XCTFail("removed record should exist")
                return
            }
            XCTAssert(recordManager.records.count == 0)
            XCTAssertEqual(record, removed)
        } catch {
            XCTFail()
        }
    }

    func testRemoveRecordDoesNotExist() {
        let task = Task(title: "Hello", frequency: .daily)
        timeEngine.simulationMode = .fixed(date(month: 1, day: 1)!)
        let removed = recordManager.removeCompletionRecord(for: task)
        XCTAssertNil(removed)
    }

    func testRemoveRecordDoesNotExistAfterPeriodChange() {
        do {
            let task = Task(title: "Hello", frequency: .daily)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1)!)
            try recordManager.createCompletionRecord(for: task)
            XCTAssert(recordManager.records.count == 1)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 2)!)
            let latest = recordManager.latestRecordInCurrentPeriod(for: task)
            XCTAssertNil(latest)
            XCTAssert(recordManager.records.count == 1)
        } catch {
            XCTFail()
        }
    }

    func testRemoveAllRecords() {
        do {
            let task = Task(title: "Hello", frequency: .daily)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1, hour: 2)!)
            try recordManager.createCompletionRecord(for: task)
            timeEngine.simulationMode = .fixed(date(month: 1, day: 1, hour: 10)!)
            try recordManager.createCompletionRecord(for: task)
            XCTAssert(recordManager.records.count == 2)
            recordManager.removeAllCompletionRecords()
            XCTAssert(recordManager.records.count == 0)
        } catch {
            XCTFail()
        }
    }

    func testRemoveAllRecordsForTask() {
        do {
            let task = Task(title: "Task", frequency: .daily)
            let otherTask = Task(title: "Other", frequency: .weekly)
            try recordManager.createCompletionRecord(for: task)
            try recordManager.createCompletionRecord(for: task)
            try recordManager.createCompletionRecord(for: task)
            try recordManager.createCompletionRecord(for: otherTask)
            try recordManager.createCompletionRecord(for: otherTask)
            try recordManager.createCompletionRecord(for: otherTask)
            XCTAssert(recordManager.records(for: task).count == 3)
            XCTAssert(recordManager.records(for: otherTask).count == 3)
            recordManager.removeAllCompletionRecords(for: task)
            XCTAssert(recordManager.records(for: task).count == 0)
            XCTAssert(recordManager.records(for: otherTask).count == 3)
        } catch {
            XCTFail()
        }
    }
}
