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
    /// Closure called when the title should reload
    var titleShouldReload: (() -> ())? { get set }
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
    var dataDidChange: ((Delta.Changes) -> ())? { get set }
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
    var editingStateDidChange: ((Bool) -> ())? { get set }
    ///
    func beginCreatingNewTask()
    ///
    func updateNewTask(title: String)
    ///
    func commitNewTask()
    /// Returns `true` if `indexPath` represents a new task row
    func indexPathRepresentsNewTaskRow(_ indexPath: IndexPath) -> Bool
    ///
    func beginEditingTask(at indexPath: IndexPath)
    ///
    func updateEditingTask(title: String)
    ///
    func commitEditingTask()
    ///
    func indexPathRepresentsEditingTaskRow(_ indexPath: IndexPath) -> Bool
    ///
    func selectedRow(at indexPath: IndexPath)
    ///
    var didBeginEditing: ((IndexPath) -> ())? { get set }
    ///
    var isEditingEnabled: Bool { get }
    ///
    func deleteTask(at indexPath: IndexPath)
    /// Returns `true` if the task at the `indexPath` is complete, otherwise `false`
    func isTaskComplete(at indexPath: IndexPath) -> Bool
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
//            DispatchQueue.main.async {
                self.editingStateDidChange?(editing)
//            }
            reloadData()
        }
    }

    // TODO: Consider renaming this, editingStateDidChange
    var editingStateDidChange: ((Bool) -> ())? = nil

    var didBeginEditing: ((IndexPath) -> ())? = nil

    // MARK: Data

    enum Section {
        case incomplete([Row])
        case complete([Row])
    }

    enum Row: Hashable {
        case task(Task)
        case newEditingTask(String)
        case newTask

        var hashValue: Int {
            switch self {
            case .task(let task): return task.hashValue
            case .newEditingTask: return "newEditingTask".hashValue
            case .newTask: return "newTask".hashValue
            }
        }

        static func == (lhs: Row, rhs: Row) -> Bool {
            switch (lhs, rhs) {
            case (.newTask, .newTask): return true
            case (.newEditingTask, .newEditingTask): return true
            case (.task(let lhsTask), .task(let rhsTask)): return lhsTask == rhsTask
            default: return false
            }
        }
    }

    var data: [Section] {
        didSet {
            func rows(from sections: [Section]) -> [[Row]] {
                return sections.map { section -> [Row] in
                    switch section {
                    case .complete(let rows): return rows
                    case .incomplete(let rows): return rows
                    }
                }
            }

            let oldRows = rows(from: oldValue)
            let newRows = rows(from: data)
            let changes = Delta.changes(between: oldRows, and: newRows)
            if changes.hasChanges {
//                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.dataDidChange?(changes)
//                }
            }
        }
    }

    var dataDidChange: ((Delta.Changes) -> ())? = nil

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

        self.dayChangeObserver.startObserving(identifier: taskFrequency.rawValue) { [weak self] in
            self?.reloadData()
            self?.titleShouldReload?()
        }

        reloadData()
    }

    deinit {
        dayChangeObserver.stopObserving(identifier: taskFrequency.rawValue)
    }

    // MARK: Helpers

    func reloadData() {
        var data = [Section]()
        if isEditing {
            let tasks = taskManager.tasks(ocurring: taskFrequency)
            var taskRows = tasks.map(toTaskRow)
            if let newTask = newTask {
                taskRows.append(.newEditingTask(newTask.title))
            }
            taskRows.append(.newTask)
            data.append(.incomplete(taskRows))
            data.append(.complete([]))
        } else {
            let (complete, incomplete) = taskManager.partitionedTasks(occuring: taskFrequency)
            let incompleteRows = incomplete.map(toTaskRow)
            let completeRows = complete.map(toTaskRow)
//            if !incompleteRows.isEmpty {
                data.append(.incomplete(incompleteRows))
//            }
//            if !completeRows.isEmpty {
                data.append(.complete(completeRows))
//            }
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

    func task(at indexPath: IndexPath) -> Task? {
        let tasks = self.tasks(in: indexPath.section)
        guard indexPath.row < tasks.endIndex else { return nil }
        return tasks[indexPath.row]
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
        do {
            let date = try timeEngine.currentPeriod(for: taskFrequency)
            let formatter = DateFormatter()
            switch taskFrequency {
            case .daily:
                formatter.dateFormat = "EEEE, MMM. d"

            case .weekly:
                let startFormatter = DateFormatter()
                let endFormatter = DateFormatter()
                switch timeEngine.calendar.compare(date.start, to: date.end, toGranularity: .month) {
                case .orderedSame:
                    startFormatter.dateFormat = "MMMM d"
                    endFormatter.dateFormat = "d"
                default:
                    startFormatter.dateFormat = "MMM. d "
                    endFormatter.dateFormat = " MMM. d"
                }
                let start = startFormatter.string(from: date.start)
                let end = endFormatter.string(from: date.end)
                return "\(start)-\(end)"

            case .monthly:
                formatter.dateFormat = "MMMM yyyy"

            }
            return formatter.string(from: date.start)

        } catch {
            // TODO: Handle the error
            switch taskFrequency {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            }
        }
    }

    var numberOfSections: Int {
        return data.count
    }

    func titleForSection(_ section: Int) -> String? {
        switch data[section] {
        case .incomplete: return nil
        case .complete(let tasks):
            if tasks.isEmpty {
                return nil
            } else {
                return "DONE"
            }
        }
    }

    var titleShouldReload: (() -> ())? = nil

    func numberOfItems(in section: Int) -> Int {
        return rows(in: section).count
    }

    func titleForTask(at indexPath: IndexPath) -> String? {
        let row = self.rows(in: indexPath.section)[indexPath.row]
        switch row {
        case .task(let task):
            if let editingTask = editingTask, indexPathRepresentsEditingTaskRow(indexPath) {
                return editingTask.title
            } else {
                return task.title
            }
        case .newTask: return nil
        case .newEditingTask(let editing): return editing
        }
    }

    func toggleTaskCompletionStatus(at indexPath: IndexPath) {
        guard !isEditing else { return }
        if let task = self.task(at: indexPath) {
            let toggledValue = !taskManager.isTaskComplete(task)
            taskManager.markTask(task, asCompleted: toggledValue)
            reloadData()
        }
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

    func indexPathRepresentsNewTaskRow(_ indexPath: IndexPath) -> Bool {
        let row = self.rows(in: indexPath.section)[indexPath.row]
        switch row {
        case .newTask: return true
        case .newEditingTask: return true
        default: return false
        }
    }

    // MARK: Edit Task

    var editingTask: Task? = nil

    func beginEditingTask(at indexPath: IndexPath) {
        editingTask = self.task(at: indexPath)
    }

    func updateEditingTask(title: String) {
        guard let editingTask = editingTask else { return }
        self.editingTask = Task(id: editingTask.id, title: title, frequency: editingTask.frequency)
    }

    func commitEditingTask() {
        guard let editingTask = editingTask else { return }
        // TODO: Determine if deleting a task title should delete the task itself - for now, no
        // TODO: Once updateTitle can throw, propogate the error through a "handleError: (Error) -> ()" closure
        // TODO: Disallow task titles to be completely empty
        taskManager.updateTitle(of: editingTask, to: editingTask.title)
    }

    func indexPathRepresentsEditingTaskRow(_ indexPath: IndexPath) -> Bool {
        guard let editingTask = editingTask else { return false }
        if let task = self.task(at: indexPath) {
            return task.id == editingTask.id
        } else {
            return false
        }
    }

    func selectedRow(at indexPath: IndexPath) {
        if isEditing {
            if indexPathRepresentsNewTaskRow(indexPath) {
                beginCreatingNewTask()
            } else {
                beginEditingTask(at: indexPath)
            }
            didBeginEditing?(indexPath)
        } else {
            toggleTaskCompletionStatus(at: indexPath)
        }
    }

    var isEditingEnabled: Bool {
        return isEditing
    }

    func deleteTask(at indexPath: IndexPath) {
        if let task = self.task(at: indexPath) {
            taskManager.deleteTask(task)
            reloadData()
        }
    }

    func isTaskComplete(at indexPath: IndexPath) -> Bool {
        if let task = self.task(at: indexPath) {
            return taskManager.isTaskComplete(task)
        } else {
            return false
        }
    }
}
