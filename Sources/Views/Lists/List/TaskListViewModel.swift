//
//  TaskListViewModel.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

/// Defines a view model that describes a task list
protocol TaskListViewModelProtocol: class {
    /// Title of the task list
    var title: String { get }
    /// Number of sections in the task list
    var numberOfSections: Int { get }
    /// Title for `section`
    func titleForSection(_ section: Int) -> String?
    /// Number of tasks in a `section`
    func numberOfTasks(in section: Int) -> Int
    /// Title for a task at an `indexPath`.
    /// Returns `nil` if a task doesn't exist at the `indexPath`.
    func titleForTask(at indexPath: IndexPath) -> String?
    /// Toggles completion status for task at `indexPath`
    func toggleTaskCompletionStatus(at indexPath: IndexPath)
    /// Closure called whenever data changes
    var dataDidChange: (() -> ())? { get set }
}

/// Describes a list of tasks
final class TaskListViewModel: TaskListViewModelProtocol {

    // MARK: Members

    let taskFrequency: TaskFrequency
    let timeEngine: TimeEngineProtocol
    let dayChangeObserver: DayChangeObserverProtocol
    let taskManager: TaskManagerProtocol

    // MARK: Properties

    enum Section {
        case complete([Task])
        case incomplete([Task])
    }

    var data: [Section]

    // MARK: Init

    init(taskFrequency: TaskFrequency,
         timeEngine: TimeEngineProtocol,
         dayChangeObserver: DayChangeObserverProtocol,
         taskManager: TaskManagerProtocol) {

        self.taskFrequency = taskFrequency
        self.timeEngine = timeEngine
        self.dayChangeObserver = dayChangeObserver
        self.taskManager = taskManager

        data = []

        self.dayChangeObserver.startObserving()
        self.dayChangeObserver.onChangesObserved = { [weak self] in
            self?.reloadData()
        }

        reloadData()
    }

    deinit {
        dayChangeObserver.stopObserving()
    }

    // MARK: Helpers

    func reloadData() {
        data = []
        let (complete, incomplete) = taskManager.partitionedTasks(occuring: taskFrequency)
        if !incomplete.isEmpty {
            data.append(.incomplete(incomplete))
        }
        if !complete.isEmpty {
            data.append(.complete(complete))
        }
        dataDidChange?()
    }

    func tasks(in section: Int) -> [Task] {
        switch data[section] {
        case .complete(let tasks): return tasks
        case .incomplete(let tasks): return tasks
        }
    }

    // MARK: Protocol

    var title: String {
        switch taskFrequency {
        case .daily:
            do {
                let formatter = DateFormatter(format: "EEEE, MMM. d")
                let date = try timeEngine.currentPeriod(for: .daily).start
                return formatter.string(from: date)
            } catch {
                // TODO: Handle the error
                return "Daily"
            }
        case .weekly:
            do {
                let formatterOne = DateFormatter(format: "MMMM d")
                let formatterTwo = DateFormatter(format: "d")
                let range = try timeEngine.currentPeriod(for: .weekly)
                let first = formatterOne.string(from: range.start)
                let second = formatterTwo.string(from: range.end)
                return "\(first)-\(second)"

            } catch {
                // TODO: Handle the error
                return "Weekly"
            }
        case .monthly:
            do {
                let formatter = DateFormatter(format: "MMMM yyyy")
                let date = try timeEngine.currentPeriod(for: .monthly).start
                return formatter.string(from: date)
            } catch {
                // TODO: Handle the error
                return "Monthly"
            }
        }
    }

    var numberOfSections: Int {
        return data.count
    }

    func titleForSection(_ section: Int) -> String? {
        switch data[section] {
        case .incomplete: return nil
        case .complete: return "DONE"
        }
    }

    func numberOfTasks(in section: Int) -> Int {
        return tasks(in: section).count
    }

    func titleForTask(at indexPath: IndexPath) -> String? {
        return tasks(in: indexPath.section)[indexPath.row].title
    }

    func toggleTaskCompletionStatus(at indexPath: IndexPath) {
        switch data[indexPath.section] {
        case .incomplete(let tasks):
            let task = tasks[indexPath.row]
            taskManager.markTask(task, asCompleted: true)
        case .complete(let tasks):
            let task = tasks[indexPath.row]
            taskManager.markTask(task, asCompleted: false)
        }
        reloadData()
    }

    var dataDidChange: (() -> ())? = nil
}
