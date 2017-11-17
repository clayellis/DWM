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

    /// Updates the `frequency` of the `task` to the `newFrequency`
    func updateFrequency(of task: Task, to newFrequency: TaskFrequency)

    /// Updates the `title` of the `task` to the `newTitle`
    func updateTitle(of task: Task, to newTitle: String)

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

    // MARK: Protocol

    var tasks: [Task] {
        do {
            return try taskDataStore.retrieveAll()
                .map { try Task(from: $0) }
        } catch {
            // TODO: Log the error
            return []
        }
    }

    func createTask(_ task: Task) {
        do {
            let preparedTask = task.prepareForStorage(in: taskDataStore.context)
            try taskDataStore.store(preparedTask)
        } catch {
            // TODO: Log the error
        }
    }

    func deleteTask(_ task: Task) {
        do {
            try taskDataStore.deleteEntity(withIdentifier: task.id)
            recordManager.removeAllCompletionRecords(for: task)
        } catch {
            // TODO: Log the error
        }
    }

    func updateFrequency(of task: Task, to newFrequency: TaskFrequency) {
        // Option 1: Replace the task entirely
        //        do {
        //            let updatedTask = Task(id: task.id, title: task.title, frequency: newFrequency)
        //            let preparedUpdatedTask = updatedTask.prepareForStorage(in: taskDataStore.context)
        //            try taskDataStore.updateEntity(withIdentifier: task.id, byReplacingWith: preparedUpdatedTask)
        //        } catch {
        //            // TODO: Log the error
        //        }

        // Option 2: Update the frequency on the stored task
        do {
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
        var tasks = self.tasks(ocurring: frequency)
        let partitionIndex = tasks.partition(by: { isTaskComplete($0) })
        let incomplete = Array(tasks[..<partitionIndex])
        let complete = Array(tasks[partitionIndex...])
        return (complete: complete, incomplete: incomplete)
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
