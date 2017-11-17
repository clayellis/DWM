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

    var timeEngine: TimeEngineProtocol = TimeEngine()
    var recordManager: RecordManagerProtocol!
    var taskDataStore: CoreDataStore<TaskData>!
    var taskManager: TaskManagerProtocol!

    override func setUp() {
        super.setUp()
        let storeURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Test.sqlite")
        // FIXME: We should just delete the the .sqlite file and start clean each time
        // For now though, deleting the object (below) works
//        try? FileManager.default.removeItem(at: storeURL)
        let stack = try! CoreDataStack(modelLocation: .bundles(Bundle.allBundles),
                                       storeLocation: .url(storeURL))
        let recordDataStore = CoreDataStore<TaskCompletionRecordData>(coreDataStack: stack)
        recordManager = RecordManager(timeEngine: timeEngine, recordDataStore: recordDataStore)
        taskDataStore = CoreDataStore(coreDataStack: stack)
        taskManager = TaskManager(timeEngine: timeEngine, recordManager: recordManager, taskDataStore: taskDataStore)
        try? taskDataStore.deleteAll()
        try? recordDataStore.deleteAll()
    }

    override func tearDown() {
        super.tearDown()
        recordManager.removeAllCompletionRecords()
        try? taskDataStore.deleteAll()
        timeEngine.resync()
    }

    func testTimeEngineBeginsUnfixed() {
        let first = timeEngine.now
        sleep(0)
        let second = timeEngine.now
        XCTAssertNotEqual(first, second)
    }

    func testTaskManagerBeginsEmpty() {
        XCTAssert(taskManager.tasks.count == 0)
    }

    func testTaskModel() {
        let id = UUID()
        let title = "Task"
        let frequency = TaskFrequency.daily
        let task = Task(id: id, title: title, frequency: frequency)
        XCTAssertEqual(task.id, id)
        XCTAssertEqual(task.title, title)
        XCTAssertEqual(task.frequency, frequency)
    }

    func testTaskFromTaskData() {
        do {
            let taskData = TaskData(context: taskDataStore.context)
            taskData.id = UUID()
            taskData.title = "Task"
            taskData.frequency = TaskFrequency.daily.rawValue
            let task = try Task(from: taskData)
            XCTAssertEqual(task.id, taskData.id)
            XCTAssertEqual(task.title, taskData.title)
            XCTAssertEqual(task.frequency, TaskFrequency(rawValue: taskData.frequency!))
        } catch {
            XCTFail()
        }
    }

    func testTaskDataFromTask() {
        let task = Task(id: UUID(), title: "Task", frequency: .weekly)
        let taskData = TaskData(from: task, in: taskDataStore.context)
        XCTAssertEqual(task.id, taskData.id)
        XCTAssertEqual(task.title, taskData.title)
        XCTAssertEqual(task.frequency, TaskFrequency(rawValue: taskData.frequency!))
    }

    func testTaskDataFromCoreDataStorable() {
        let task = Task(id: UUID(), title: "Task", frequency: .weekly)
        let taskData = task.prepareForStorage(in: taskDataStore.context)
        XCTAssertEqual(task.id, taskData.id)
        XCTAssertEqual(task.title, taskData.title)
        XCTAssertEqual(task.frequency, TaskFrequency(rawValue: taskData.frequency!))
    }

    func testCreateTaskThenRetrieve() {
        let task = Task(title: "Task", frequency: .daily)
        taskManager.createTask(task)
        let tasks = taskManager.tasks
        XCTAssert(tasks.count == 1)
        guard let testTask = tasks.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(testTask.id, task.id)
        XCTAssertEqual(testTask.title, task.title)
        XCTAssertEqual(testTask.frequency, task.frequency)
    }

    func testTaskEqualityShouldEqual() {
        let id = UUID()
        let first = Task(id: id, title: "First", frequency: .daily)
        let copy = Task(id: id, title: "First", frequency: .daily)
        XCTAssertEqual(first, copy)
    }

    func testTaskEqualityShouldNotEqualDifferentID() {
        let first = Task(id: UUID(), title: "First", frequency: .daily)
        let copy = Task(id: UUID(), title: "First", frequency: .daily)
        XCTAssertNotEqual(first, copy)
    }

    func testTaskEqualityShouldNotEqualDifferentTitle() {
        let id = UUID()
        let first = Task(id: id, title: "First", frequency: .daily)
        let copy = Task(id: id, title: "Not The Same", frequency: .daily)
        XCTAssertNotEqual(first, copy)
    }

    func testTaskEqualityShouldNotEqualDifferentFrequency() {
        let id = UUID()
        let first = Task(id: id, title: "First", frequency: .daily)
        let copy = Task(id: id, title: "First", frequency: .weekly)
        XCTAssertNotEqual(first, copy)
    }

    func testCreatedTaskEqualsInputTask() {
        let task = Task(title: "Task", frequency: .weekly)
        taskManager.createTask(task)
        XCTAssert(taskManager.tasks.count == 1)
        guard let created = taskManager.tasks.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(task, created)
    }

    func testCreateTaskThenDelete() {
        let task = Task(title: "Task", frequency: .daily)
        taskManager.createTask(task)
        XCTAssert(taskManager.tasks.count == 1)
        taskManager.deleteTask(task)
        XCTAssert(taskManager.tasks.count == 0)
    }

    func testUpdateTaskFrequency() {
        let originalFrequency = TaskFrequency.daily
        let updatedFrequency = TaskFrequency.weekly
        let task = Task(title: "Task", frequency: originalFrequency)
        taskManager.createTask(task)
        let tasks = taskManager.tasks
        XCTAssert(tasks.count == 1)
        guard let testTask = tasks.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(testTask.frequency, originalFrequency)
        taskManager.updateFrequency(of: task, to: updatedFrequency)
        let refreshedTasks = taskManager.tasks
        XCTAssert(refreshedTasks.count == 1)
        guard let testTaskTwo = refreshedTasks.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(testTaskTwo.frequency, updatedFrequency)
    }

    func testUpdateTaskTitle() {
        let originalTitle = "Task"
        let updatedTitle = "Updated"
        let task = Task(title: originalTitle, frequency: .monthly)
        taskManager.createTask(task)
        XCTAssert(taskManager.tasks.count == 1)
        guard let first = taskManager.tasks.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(first.title, originalTitle)

        taskManager.updateTitle(of: task, to: updatedTitle)
        guard let second = taskManager.tasks.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(second.title, updatedTitle)
    }

    func testMarkTestComplete() {
        let task = Task(title: "Task", frequency: .daily)
        taskManager.createTask(task)
        timeEngine.now = date(month: 1, day: 1)!
        do {
            taskManager.markTask(task, asCompleted: true)
            XCTAssert(recordManager.records.count == 1)
            let records = recordManager.records(for: task)
            XCTAssert(records.count == 1)
            guard let last = records.last else {
                XCTFail()
                return
            }
            XCTAssertEqual(last.timestamp, timeEngine.now)
            let latest = recordManager.latestRecord(for: task)
            XCTAssertEqual(latest, last)
            let latestCurrent = recordManager.latestRecordInCurrentPeriod(for: task)
            XCTAssertEqual(latestCurrent, last)
        }

        do {
            taskManager.markTask(task, asCompleted: false)
            XCTAssert(recordManager.records.count == 0)
            XCTAssertNil(recordManager.latestRecord(for: task))
            XCTAssertNil(recordManager.latestRecordInCurrentPeriod(for: task))
        }
    }

    func testTasksByFrequency() {
        let dailyCount = 2
        let weeklyCount = 3
        let monthlyCount = 4

        create(dailyCount, tasksOccuring: .daily)
        create(weeklyCount, tasksOccuring: .weekly)
        create(monthlyCount, tasksOccuring: .monthly)

        let daily = taskManager.tasks(ocurring: .daily)
        let weekly = taskManager.tasks(ocurring: .weekly)
        let monthly = taskManager.tasks(ocurring: .monthly)

        XCTAssertEqual(daily.count, dailyCount)
        XCTAssertEqual(weekly.count, weeklyCount)
        XCTAssertEqual(monthly.count, monthlyCount)

        let all = taskManager.tasks
        let totalCount = dailyCount + weeklyCount + monthlyCount
        XCTAssertEqual(all.count, totalCount)
    }

    func testTasksByFrequencyCompleted() {
        create(3, tasksOccuring: .daily)
        let dailyTasks = taskManager.tasks(ocurring: .daily)
        taskManager.markTask(dailyTasks[1], asCompleted: true)
        let dailyComplete = taskManager.tasks(ocurring: .daily, markedCompleted: true)
        let dailyIncomplete = taskManager.tasks(ocurring: .daily, markedCompleted: false)
        XCTAssert(dailyComplete.count == 1)
        XCTAssert(dailyIncomplete.count == 2)
    }

    func testRecordsDeletedWhenTaskDelete() {
        let task = Task(title: "Task", frequency: .weekly)
        taskManager.createTask(task)
        taskManager.markTask(task, asCompleted: true)
        taskManager.markTask(task, asCompleted: true)
        taskManager.markTask(task, asCompleted: true)
        XCTAssertEqual(recordManager.records(for: task).count, 3)
        taskManager.deleteTask(task)
        XCTAssertEqual(recordManager.records(for: task).count, 0)
    }

    func testPartitionedTasksByFrequency() {
        create(4, tasksOccuring: .daily)
        let dailyTasks = taskManager.tasks(ocurring: .daily)
        let firstDaily = dailyTasks[0]
        let secondDaily = dailyTasks[1]
        taskManager.markTask(firstDaily, asCompleted: true)
        taskManager.markTask(secondDaily, asCompleted: true)
        let partitions = taskManager.partitionedTasks(occuring: .daily)
        XCTAssertEqual(partitions.complete.count, 2)
        XCTAssert(partitions.complete.contains(firstDaily))
        XCTAssert(partitions.complete.contains(secondDaily))
        XCTAssertEqual(partitions.incomplete.count, 2)
    }

    func testPartitionedTasksByFrequencyOverPeriodChange() {
        let daily = create(4, tasksOccuring: .daily)
        timeEngine.now = date(month: 1, day: 1)!
        taskManager.markTask(daily[0], asCompleted: true)
        timeEngine.now = date(month: 1, day: 3)!
        taskManager.markTask(daily[1], asCompleted: true)
        let partitions = taskManager.partitionedTasks(occuring: .daily)
        XCTAssertEqual(partitions.complete.count, 1)
        XCTAssert(partitions.complete.contains(daily[1]))
        XCTAssertEqual(partitions.incomplete.count, 3)
    }

    func testTaskListGeneration() {
        let dailyCount = 2
        let weeklyCount = 3
        let monthlyCount = 5
        create(dailyCount, tasksOccuring: .daily)
        create(weeklyCount, tasksOccuring: .weekly)
        create(monthlyCount, tasksOccuring: .monthly)
        let taskList = taskManager.generateTaskLists()
        XCTAssertEqual(taskList.daily.count, dailyCount)
        XCTAssertEqual(taskList.weekly.count, weeklyCount)
        XCTAssertEqual(taskList.monthly.count, monthlyCount)
    }

    func testPartitionedTaskListGeneration() {
        let daily = create(2, tasksOccuring: .daily)
        let weekly = create(3, tasksOccuring: .weekly)
        let monthly = create(5, tasksOccuring: .monthly)
        taskManager.markTask(daily[1], asCompleted: true)
        taskManager.markTask(weekly[0], asCompleted: true)
        taskManager.markTask(weekly[1], asCompleted: true)
        taskManager.markTask(monthly[0], asCompleted: true)
        let taskList = taskManager.generatePartitionedTaskLists()
        XCTAssertEqual(taskList.daily.complete.count, 1)
        XCTAssertEqual(taskList.daily.incomplete.count, 1)
        XCTAssertEqual(taskList.weekly.complete.count, 2)
        XCTAssertEqual(taskList.weekly.incomplete.count, 1)
        XCTAssertEqual(taskList.monthly.complete.count, 1)
        XCTAssertEqual(taskList.monthly.incomplete.count, 4)
    }

    func testPartitionedTaskListGenerationOverPeriodChange() {
        let daily = create(2, tasksOccuring: .daily)
        let weekly = create(3, tasksOccuring: .weekly)
        let monthly = create(5, tasksOccuring: .monthly)
        timeEngine.now = date(month: 1, day: 1)!
        taskManager.markTask(daily[1], asCompleted: true)
        timeEngine.now = date(month: 1, day: 8)!
        taskManager.markTask(weekly[0], asCompleted: true)
        timeEngine.now = date(month: 1, day: 20)!
        taskManager.markTask(weekly[1], asCompleted: true)
        taskManager.markTask(monthly[0], asCompleted: true)
        let taskList = taskManager.generatePartitionedTaskLists()
        XCTAssertEqual(taskList.daily.complete.count, 0)
        XCTAssertEqual(taskList.daily.incomplete.count, 2)
        XCTAssertEqual(taskList.weekly.complete.count, 1)
        XCTAssertEqual(taskList.weekly.incomplete.count, 2)
        XCTAssertEqual(taskList.monthly.complete.count, 1)
        XCTAssertEqual(taskList.monthly.incomplete.count, 4)
    }
}

// MARK: - Helpers

extension TaskManagerTests {
    @discardableResult func create(_ count: Int, tasksOccuring frequency: TaskFrequency) -> [Task] {
        var tasks = [Task]()
        for index in 1 ... count {
            let task = Task(title: "\(frequency.rawValue) \(index)", frequency: frequency)
            tasks.append(task)
            taskManager.createTask(task)
        }
        return tasks
    }
}
