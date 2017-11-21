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
    /// Number of items in a `section`
    func numberOfItems(in section: Int) -> Int
    /// Title for a task at an `indexPath`.
    /// Returns `nil` if a task doesn't exist at the `indexPath`.
    func titleForTask(at indexPath: IndexPath) -> String?
    /// Toggles completion status for task at `indexPath`
    func toggleTaskCompletionStatus(at indexPath: IndexPath)
    /// Closure called whenever data changes
    var dataDidChange: (() -> ())? { get set }
    /// Begins editing the task list
    func beginEditing()
    /// Ends editing the task list
    func endEditing()
    /// Toggles editing the task list
    func toggleEditing()
    /// Title for edit button (changes with state)
    var editButtonTitle: String { get }
    /// Closure called whenever editing changes.
    /// Parameter is `true` if editing, otherwise `false`.
    var editingDidChange: ((Bool) -> ())? { get set }
    /// Returns `true` if `indexPath` represents a new task row
    func indexPathRepresentsNewTaskRow(_ indexPath: IndexPath) -> Bool
    ///
    func beginCreatingNewTask()
    ///
    func updateNewTask(title: String)
    ///
    func commitNewTask()
}

/// Describes a list of tasks
final class TaskListViewModel: TaskListViewModelProtocol {

    // MARK: Members

    let taskFrequency: TaskFrequency
    let timeEngine: TimeEngineProtocol
    let dayChangeObserver: DayChangeObserverProtocol
    let taskManager: TaskManagerProtocol

    // MARK: - Properties

    // MARK: State

    enum State {
        case normal
        case editing
    }

    var state: State {
        didSet {
            let editing = state == .editing
            editingDidChange?(editing)
            reloadData()
        }
    }

    var editingDidChange: ((Bool) -> ())? = nil

    // MARK: Data

    enum Section {
        case incomplete([Row])
        case complete([Row])
    }

    enum Row {
        case task(Task)
        // case editingTask(Task)
        case newEditingTask(String)
        case newTask
    }

    var data: [Section] {
        didSet {
            dataDidChange?()
        }
    }

    var dataDidChange: (() -> ())? = nil

    // MARK: - Init

    init(taskFrequency: TaskFrequency,
         timeEngine: TimeEngineProtocol,
         dayChangeObserver: DayChangeObserverProtocol,
         taskManager: TaskManagerProtocol) {

        self.taskFrequency = taskFrequency
        self.timeEngine = timeEngine
        self.dayChangeObserver = dayChangeObserver
        self.taskManager = taskManager

        state = .normal
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
        var data = [Section]()
        let (complete, incomplete) = taskManager.partitionedTasks(occuring: taskFrequency)
        var incompleteRows = incomplete.map(toTaskRow)
        let completeRows = complete.map(toTaskRow)
        switch state {
        case .editing:
            if let newTask = newTask {
                incompleteRows.append(.newEditingTask(newTask.title))
            }
            incompleteRows.append(.newTask)
        case .normal: break
        }
        if !incompleteRows.isEmpty {
            data.append(.incomplete(incompleteRows))
        }
        if !completeRows.isEmpty {
            data.append(.complete(completeRows))
        }
        self.data = data
    }

    func rows(in section: Int) -> [Row] {
        switch data[section] {
        case .incomplete(let rows): return rows
        case .complete(let rows): return rows
        }
    }

    func tasks(in section: Int) -> [Task] {
        return rows(in: section).flatMap(toTask)
    }

    func toTaskRow(_ task: Task) -> Row {
        return Row.task(task)
    }

    func toTask(_ row: Row) -> Task? {
        switch row {
        case .task(let task): return task
        case .newTask: return nil
        case .newEditingTask: return nil
        }
    }

    var isEditing: Bool {
        switch state {
        case .editing: return true
        case .normal: return false
        }
    }

    // MARK: - Protocol

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

    func numberOfItems(in section: Int) -> Int {
        return rows(in: section).count
    }

    func titleForTask(at indexPath: IndexPath) -> String? {
        let row = self.rows(in: indexPath.section)[indexPath.row]
        switch row {
        case .task(let task): return task.title
        case .newTask: return nil
        case .newEditingTask(let editing): return editing
        }
    }

    func toggleTaskCompletionStatus(at indexPath: IndexPath) {
        guard !isEditing else { return }

        switch data[indexPath.section] {
        case .incomplete(let rows):
            let tasks = rows.flatMap(toTask)
            let task = tasks[indexPath.row]
            taskManager.markTask(task, asCompleted: true)
        case .complete(let rows):
            let tasks = rows.flatMap(toTask)
            let task = tasks[indexPath.row]
            taskManager.markTask(task, asCompleted: false)
        }
        reloadData()
    }

    func beginEditing() {
        state = .editing
    }

    func endEditing() {
        state = .normal
    }

    func toggleEditing() {
        switch state {
        case .normal: beginEditing()
        case .editing: endEditing()
        }
    }

    var editButtonTitle: String {
        if isEditing {
            return "Done"
        } else {
            return "Edit"
        }
    }

    // MARK: New Task

    func indexPathRepresentsNewTaskRow(_ indexPath: IndexPath) -> Bool {
        let row = self.rows(in: indexPath.section)[indexPath.row]
        switch row {
        case .newTask: return true
        case .newEditingTask: return true
        default: return false
        }
    }

    var newTask: Task? = nil

    func beginCreatingNewTask() {
        newTask = Task(title: "", frequency: taskFrequency)
//        reloadData()
    }

    func updateNewTask(title: String) {
        guard let newTask = newTask else { return }
        self.newTask = Task(id: newTask.id, title: title, frequency: newTask.frequency)
    }

    func commitNewTask() {
        guard let newTask = newTask else { return }
        if !newTask.title.isEmpty {
            taskManager.createTask(newTask)
        }
        self.newTask = nil
        reloadData()
    }
}
