//
//  TaskManagerTests.swift
//  DWMTests
//
//  Created by Clay Ellis on 11/13/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest
@testable import DWM

class TaskManagerTests: XCTestCase {

    let timeEngine: TimeEngineProtocol = TimeEngine()
    var recordManager: RecordManagerProtocol!
    var taskDataStore: CoreDataStore<TaskData>!
    var taskManager: TaskManagerProtocol!

    override func setUp() {
        super.setUp()
        let storeURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
            .appendingPathComponent("Test.sqlite")
        let stack = try! CoreDataStack(
            modelLocation: .bundles(Bundle.allBundles),
            storeLocation: .url(storeURL))
        let recordDataStore = CoreDataStore<TaskCompletionRecordData>(coreDataStack: stack)
        recordManager = RecordManager(timeEngine: timeEngine, recordDataStore: recordDataStore)
        taskDataStore = CoreDataStore(coreDataStack: stack)
        taskManager = TaskManager(timeEngine: timeEngine, recordManager: recordManager, taskDataStore: taskDataStore)
    }

    override func tearDown() {
        super.tearDown()
        recordManager.removeAllCompletionRecords()
        try? taskDataStore.deleteAll()
        timeEngine.resync()
    }

    // create tasks, retrieve tasks (createTask, tasks)
//    func testCreateRetrieveTask() {
//        let taskManager = TaskManager(timeEngine: <#T##TimeEngineProtocol#>, recordManager: <#T##RecordManagerProtocol#>, taskDataStore: <#T##CoreDataStore<TaskData>#>)
//    }

    // create task, delete (createTask, delete)

    // delete task (create, retrieve, delete, retrieve)

    // update frequency (create, retrieve, update, retrieve)

    // mark task complete/incomplete

    // tasks occuring in frequency create tasks in multiple frequencies, retrieve subset

    // tasks occuring in frequency complete/incomplete (create multiple frequencies, mark some complete, retrieve subset)

    // create task, mark complete multiple times, delete task, check to make sure that the completion records are deleted (regardless of current period)

}
