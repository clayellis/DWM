//
//  TaskManager.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

/// Defines a manager for `Task`s
protocol TaskManagerProtocol {
    /// A tuple containing an array of completed `Task`s and an array of incomplete `Task`s
    typealias PartitionedTaskList = (complete: [Task], incomplete: [Task])

    /// All `Task`s
    var tasks: [Task] { get }

    /// Creates and stores a `Task`
    func createTask(_ task: Task)

    /// Deletes a `Task` and all `TaskCompletionRecord`s associated with it
    func deleteTask(_ task: Task)

    /// Deletes all `Task`s
    func deleteAllTasks()

    /// Updates the `frequency` of the `task` to the `newFrequency`
    func updateFrequency(of task: Task, to newFrequency: TaskFrequency)

    /// Updates the `title` of the `task` to the `newTitle`
    func updateTitle(of task: Task, to newTitle: String)

    /// Updates the `displayOrder` of the `task` to precede the `nextTask` and all other tasks that follow
    /// If `nextTask` is `nil`, the `task` will be ordered at the end of the list.
    func updateDisplayOrder(of task: Task, precedes nextTask: Task?)

    /// Marks the `task` as completed or incomplete
    func markTask(_ task: Task, asCompleted completed: Bool)

    /// Returns `Task`s whose `frequency` matches the provided `TaskFrequency`
    func tasks(ocurring frequency: TaskFrequency) -> [Task]

    /// Returns `Task`s whose `frequency` matches the provided `TaskFrequency` and that either marked completed or incomplete
    func tasks(ocurring frequency: TaskFrequency, markedCompleted: Bool) -> [Task]

    /// Returns a `PartitionedTaskList` of `Task`s whose `frequency`'s match the provided `TaskFrequency`
    func partitionedTasks(occuring frequency: TaskFrequency) -> PartitionedTaskList

    /// Returns three arrays of `Task`s separated by their respective `frequency`'s
    func generateTaskLists() -> (daily: [Task], weekly: [Task], monthly: [Task])

    /// Returns three arrays of `PartitionTaskList`s separated by their respective `frequency`'s
    func generatePartitionedTaskLists() -> (daily: PartitionedTaskList, weekly: PartitionedTaskList, monthly: PartitionedTaskList)
}

final class TaskManager: TaskManagerProtocol {
    let timeEngine: TimeEngineProtocol
    let recordManager: RecordManagerProtocol
    let taskDataStore: CoreDataStore<TaskData>

    init(timeEngine: TimeEngineProtocol,
         recordManager: RecordManagerProtocol,
         taskDataStore: CoreDataStore<TaskData>) {
        self.timeEngine = timeEngine
        self.recordManager = recordManager
        self.taskDataStore = taskDataStore
    }

    // MARK: Helpers

    func isTaskComplete(_ task: Task) -> Bool {
        return recordManager.latestRecordInCurrentPeriod(for: task) != nil
    }

    func byDisplayOrder(_ lhs: TaskData, _ rhs: TaskData) -> Bool {
        return lhs.displayOrder < rhs.displayOrder
    }

    func toTask(_ taskData: TaskData) -> Task? {
        do {
            return try Task(from: taskData)
        } catch {
            // TODO: Log the error
            return nil
        }
    }

    // MARK: Protocol

    var tasks: [Task] {
        do {
            return try taskDataStore.retrieveAll()
                .sorted { $0.displayOrder < $1.displayOrder }
                .map { try Task(from: $0) }
        } catch {
            // TODO: Log the error
            return []
        }
    }

    func createTask(_ task: Task) {
        do {
            // TODO: Disallow tasks with duplicate names, throw an error
            // TODO: Update the display order of the other tasks

            let _tasks = try taskDataStore.retrieveAll()
                .filter { $0.frequency == task.frequency.rawValue }

            let newDisplayOrder: Int16
            if let displayOrder = _tasks.map({ $0.displayOrder }).max() {
                newDisplayOrder = displayOrder + 1
            } else {
                newDisplayOrder = 0
            }

            let preparedTask = task.prepareForStorage(in: taskDataStore.context)
            preparedTask.displayOrder = newDisplayOrder
            try taskDataStore.store(preparedTask)
        } catch {
            // TODO: Log the error
        }
    }

    func deleteTask(_ task: Task) {
        do {
            // TODO: Update the display order of the other tasks

            try taskDataStore.deleteEntity(withIdentifier: task.id)
            recordManager.removeAllCompletionRecords(for: task)
        } catch {
            // TODO: Log the error
        }
    }

    func deleteAllTasks() {
        do {
            try taskDataStore.deleteAll()
            recordManager.removeAllCompletionRecords()
        } catch {
            // TODO: Log the error
        }
    }

    func updateFrequency(of task: Task, to newFrequency: TaskFrequency) {
        do {
            // TODO: Update the display order of just this task (stick it on the end)
            try taskDataStore.updateEntity(withIdentifier: task.id) { task in
                task.frequency = newFrequency.rawValue
            }
        } catch {
            // TODO: Log the error
        }

        // TODO: Create a delegate and inform it of task changes
    }

    func updateTitle(of task: Task, to newTitle: String) {
        do {
            try taskDataStore.updateEntity(withIdentifier: task.id) { task in
                task.title = newTitle
            }
        } catch {
            // TODO: Log the error
            // FIXME: In this case, it would be a good idea to propogate the error up so the view can react
        }
    }

    func updateDisplayOrder(of task: Task, precedes nextTask: Task?) {
        do {

            let newDisplayOrder: Int16 = 0

            // TODO: Calculate the new display order based on the nextTask
            // TODO: All tasks at and after `newDisplayOrder` will be adjusted by one

            try taskDataStore.updateEntity(withIdentifier: task.id) { task in
                task.displayOrder = newDisplayOrder
            }
        } catch {
            // TODO: Log the error
            // FIXME: In this case, it would be a good idea to propogate the error up so the view can react
        }
    }

    func markTask(_ task: Task, asCompleted completed: Bool) {
        if completed {
            do {
                try recordManager.createCompletionRecord(for: task)
            } catch {
                // TODO: Handle the error
            }
        } else {
            recordManager.removeCompletionRecord(for: task)
        }
    }

    func tasks(ocurring frequency: TaskFrequency) -> [Task] {
        return tasks.filter { $0.frequency == frequency }
    }

    func tasks(ocurring frequency: TaskFrequency, markedCompleted: Bool) -> [Task] {
        let tasks = self.tasks(ocurring: frequency)
        return tasks.filter { isTaskComplete($0) == markedCompleted }
    }

    func partitionedTasks(occuring frequency: TaskFrequency) -> TaskManagerProtocol.PartitionedTaskList {
        do {
            var _tasks = try taskDataStore.retrieveAll()
                .filter { $0.frequency == frequency.rawValue }
            let partitionIndex = _tasks.partition {
                let task = try! Task(from: $0)
                return isTaskComplete(task)
            }
            let incomplete = Array(_tasks[..<partitionIndex]).sorted(by: byDisplayOrder).flatMap(toTask)
            let complete = Array(_tasks[partitionIndex...]).sorted(by: byDisplayOrder).flatMap(toTask)
            return (complete: complete, incomplete: incomplete)
        } catch {
            // TODO: Handle the error
            return (complete: [], incomplete: [])
        }
    }

    func generateTaskLists() -> (daily: [Task], weekly: [Task], monthly: [Task]) {
        let daily = tasks(ocurring: .daily)
        let weekly = tasks(ocurring: .weekly)
        let monthly = tasks(ocurring: .monthly)
        return (daily: daily, weekly: weekly, monthly: monthly)
    }

    func generatePartitionedTaskLists() -> (
        daily: TaskManagerProtocol.PartitionedTaskList,
        weekly: TaskManagerProtocol.PartitionedTaskList,
        monthly: TaskManagerProtocol.PartitionedTaskList) {

            let daily = partitionedTasks(occuring: .daily)
            let weekly = partitionedTasks(occuring: .weekly)
            let monthly = partitionedTasks(occuring: .monthly)
            return (daily: daily, weekly: weekly, monthly: monthly)
    }
}
