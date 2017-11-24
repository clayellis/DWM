//
//  TaskListTests.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest
@testable import DWM

class TaskListTests: XCTestCase {

    var store: SimpleStoreProtocol!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testListTitleDaily() {
        let timeEngine = TimeEngine()
        let dayChangeObserver = DayChangeObserver(storage: store, timeEngine: timeEngine)
        let viewModel = TaskListViewModel(taskFrequency: .daily, timeEngine: timeEngine, dayChangeObserver: dayChangeObserver, taskManager: MockTaskManager(tasks: []))
        timeEngine.simulationMode = .fixed(date(month: 11, day: 19, year: 2017)!)
        XCTAssertEqual(viewModel.title, "Sunday, Nov. 19")
    }

    func testListTitleWeekly() {
        let timeEngine = TimeEngine()
        let dayChangeObserver = DayChangeObserver(storage: store, timeEngine: timeEngine)
        let viewModel = TaskListViewModel(taskFrequency: .weekly, timeEngine: timeEngine, dayChangeObserver: dayChangeObserver, taskManager: MockTaskManager(tasks: []))
        timeEngine.simulationMode = .fixed(date(month: 11, day: 19, year: 2017)!)
        XCTAssertEqual(viewModel.title, "November 19-25")
    }

    func testListTitleWeeklySplitMonth() {
        let timeEngine = TimeEngine()
        let dayChangeObserver = DayChangeObserver(storage: store, timeEngine: timeEngine)
        let viewModel = TaskListViewModel(taskFrequency: .weekly, timeEngine: timeEngine, dayChangeObserver: dayChangeObserver, taskManager: MockTaskManager(tasks: []))
        timeEngine.simulationMode = .fixed(date(month: 11, day: 26, year: 2017)!)
        XCTAssertEqual(viewModel.title, "Nov. 26 - Dec. 2")
    }

    func testListTitleMonthly() {
        let timeEngine = TimeEngine()
        let dayChangeObserver = DayChangeObserver(storage: store, timeEngine: timeEngine)
        let viewModel = TaskListViewModel(taskFrequency: .monthly, timeEngine: timeEngine, dayChangeObserver: dayChangeObserver, taskManager: MockTaskManager(tasks: []))
        timeEngine.simulationMode = .fixed(date(month: 11, day: 19, year: 2017)!)
        XCTAssertEqual(viewModel.title, "November 2017")
    }
}

class MockTaskManager: TaskManagerProtocol {

    init(tasks: [Task]) {
        self.tasks = tasks
    }

    var tasks: [Task]

    func createTask(_ task: Task) {
        tasks.append(task)
    }

    func deleteTask(_ task: Task) {
        guard let index = tasks.index(of: task) else { return }
        tasks.remove(at: index)
    }

    func deleteAllTasks() {
        tasks = []
    }

    func updateFrequency(of task: Task, to newFrequency: TaskFrequency) {
        let updated = Task(id: task.id, title: task.title, frequency: newFrequency)
        replace(task, with: updated)
    }

    func updateTitle(of task: Task, to newTitle: String) {
        let updated = Task(id: task.id, title: newTitle, frequency: task.frequency)
        replace(task, with: updated)
    }

    func updateDisplayOrder(of task: Task, precedes nextTask: Task?) {
        // TODO: Implement
    }

    func markTask(_ task: Task, asCompleted completed: Bool) {
        // TODO: Implement
    }

    func tasks(ocurring frequency: TaskFrequency) -> [Task] {
        return tasks.filter { $0.frequency == frequency }
    }

    func tasks(ocurring frequency: TaskFrequency, markedCompleted: Bool) -> [Task] {
        // TODO: Implement
        return []
    }

    func partitionedTasks(occuring frequency: TaskFrequency) -> TaskManagerProtocol.PartitionedTaskList {
        return (complete: [], incomplete: [])
    }

    func generateTaskLists() -> (daily: [Task], weekly: [Task], monthly: [Task]) {
        return (daily: [], weekly: [], monthly: [])
    }

    func generatePartitionedTaskLists() -> (daily: TaskManagerProtocol.PartitionedTaskList, weekly: TaskManagerProtocol.PartitionedTaskList, monthly: TaskManagerProtocol.PartitionedTaskList) {
        return (daily: (complete: [], incomplete: []),
                weekly: (complete: [], incomplete: []),
                monthly: (complete: [], incomplete: []))
    }

    // MARK: Helpers

    func replace(_ task: Task, with replacement: Task) {
        guard let index = tasks.index(of: task) else { return }
        tasks.remove(at: index)
        tasks.insert(replacement, at: index)
    }
}
