//
//  TaskListViewModel.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import CoreGraphics

/// Defines a view model that describes a task list
protocol TaskListViewModelProtocol: class {

    /// The `TaskListViewModelDelegate` that this view model sends events to.
    weak var delegate: TaskListViewModelDelegate? { get set }

    // Inputs

    /// Tells the view model that the user selected the row at the index path
    /// - parameter indexPath: The `IndexPath` of the row that was selected
    func didSelectRow(at indexPath: IndexPath)

    /// Tells the view model that the user tapped the edit button
    func didTapEditButton()

    /// Tells the view model that the user tapped the status indicator at the index path.
    /// - parameter indexPath: The `IndexPath` of the row containing the tapped status indicator.
    func didTapStatusIndicator(at indexPath: IndexPath)

    /// Tells the view model that the user tapped delete at the index path.
    /// - parameter indexPath: The `IndexPath` of the row containing the tapped delete button.
    func didTapDelete(at indexPath: IndexPath)

    /// Tells the view model that a text view at an index path did begin editing.
    /// - parameter indexPath: The `IndexPath` of the row containing the text view.
    func didBeginEditingText(at indexPath: IndexPath)

    /// Tells the view model that a the text view at an index path did end editing.
    /// - parameter indexPath: The `IndexPath` of the row containing the text view.
    func didEndEditingText(at indexPath: IndexPath)

    /// Tells the view model that the user tapped to dismiss the keyboard
    func didTapToDismissKeyboard()

    /// Tells the view model to begin editing the task at the index path.
    /// - parameter indexPath: The `IndexPath` of the row to edit.
    func beginEditingTask(at indexPath: IndexPath)

    /// Tells the view model to update the title of the editing task.
    /// - parameter title: The udpated title.
    func updateEditingTask(title: String)

    /// Tells the view model to commit the editing task edits.
    func commitEditingTask()

    /// Tells the view model to begin creating a new task.
    func beginCreatingNewTask()

    /// Tells the view model to update the new task title.
    /// - parameter title: The updated title.
    func updateNewTask(title: String)

    /// Tells the view model to commit the new task edits.
    func commitNewTask()

    /// Tells the view model that the keyboard's frame will change.
    /// - parameter fromFrame: The keyboard's current frame.
    /// - parameter toFrame: The keyboard's new frame.
    func keyboardFrameWillChange(from fromFrame: CGRect, to toFrame: CGRect)

    // Outputs

    /// Returns the title of the task list.
    var title: String { get }

    /// Returns the title for edit button (changes with state).
    var editButtonTitle: String { get }

    /// Returns the number of sections in the task list.
    var numberOfSections: Int { get }

    /// Returns the title for `section`.
    func titleForSection(_ section: Int) -> String?

    /// Returns the number of items in a `section`.
    func numberOfItems(in section: Int) -> Int

    /// Returns the title for a task at an index path.
    /// - returns: `nil` if a task doesn't exist at the `indexPath`.
    func titleForTask(at indexPath: IndexPath) -> String?

    /// Returns the placeholder text for a task at an index path.
    /// - returns: The placeholder text the task at `indexPath`.
    func placeholderForTask(at indexPath: IndexPath) -> String

    /// Returns whether the text view at the index path can be edited.
    /// - parameter indexPath: The `IndexPath` of the row containing the text view.
    /// - returns: Whether the text view at the `indexPath` can be edited.
    func canEditTextView(at indexPath: IndexPath) -> Bool

    /// Returns whether the row at the index path can be edited.
    /// - parameter indexPath: The `IndexPath` of the row.
    /// - returns: Whether the row at the `indexPath` can be edited.
    func canEditRow(at indexPath: IndexPath) -> Bool

    /// Returns whether the index path represents a completed task.
    /// - parameter indexPath: The `IndexPath` of the inquiry.
    /// - returns: Whether the `indexPath` represents a completed task.
    func indexPathRepresentsCompletedTask(_ indexPath: IndexPath) -> Bool

    /// Returns whether the index path represents the editing task row.
    /// - parameter indexPath: The `IndexPath` of the inquiry.
    /// - returns: Whether the `indexPath` represents the editing task row.
    func indexPathRepresentsEditingTaskRow(_ indexPath: IndexPath) -> Bool

    /// Returns whether the index path represents the new task row.
    /// - parameter indexPath: The `IndexPath` of the inquiry.
    /// - returns: Whether the `indexPath` represents the new task row.
    func indexPathRepresentsNewTaskRow(_ indexPath: IndexPath) -> Bool
}

/// A delegate that responds to events sent by a `TaskListViewModel`.
protocol TaskListViewModelDelegate: class {

    // TODO: Update wording to remove "should"

    /// Called when the title should be set.
    /// - parameter newTitle: The new title.
    func setTitle(to newTitle: String)

    /// Called when the row at the index path should update its selection state.
    /// - parameter selected: Whether the row should be selected.
    /// - parameter indexPath: The `IndexPath` of the row.
    func updateRowSelectionState(to selected: Bool, animated: Bool, at indexPath: IndexPath)

    /// Called when the appearance of a task list cell at an index path should be set.
    /// - parameter completed: Whether the appearance should be the completed appearance.
    /// - parameter indexPath: The `IndexPath` of the row.
    /// - parameter animated: Whether the update should be animated.
    func updateRowAppearance(toCompleted completed: Bool, at indexPath: IndexPath, animated: Bool)

    /// Called when the data should be reload.
    /// - parameter changes: The changes which occurred.
    func reloadData(with changes: Delta.Changes)

    /// Called when the text view at the index path should change interaction enabled state.
    /// - parameter shouldEnable: Whether the text view's interaction should be enabled.
    /// - parameter indexPath: The `IndexPath` of the row containing the text view
    func enableInteractionWithTextView(_ shouldEnable: Bool, at indexPath: IndexPath)

    /// Called when the text view at the index path should clear its text.
    /// - parameter indexPath: The `IndexPath` of the row containing the text view.
    func clearText(at indexPath: IndexPath)

    /// Called when the edit button title should be set.
    /// - parameter newTitle: The new title.
    func setEditButtonTitle(to newTitle: String)

    /// Called when the view should change editing state.
    /// - parameter editing: Whether the view should be in editing state.
    func changeEditingState(to editing: Bool)

    /// Called when the text view at the index path should begin editing
    func beginEditingTextView(at indexPath: IndexPath)

    /// Called when the keyboard should be dismissed
    func dismissKeyboard()

    /// Called when the view should trigger feedback that a task was completed
    func triggerTaskCompletionFeedback()

    /// Called when the task list's bottom content inset should be set.
    func setTaskListBottomInset(to newInset: CGFloat)
}

/// Describes a list of tasks
final class TaskListViewModel: TaskListViewModelProtocol {

    var delegate: TaskListViewModelDelegate?

    // MARK: Members

    let taskFrequency: TaskFrequency
    let timeEngine: TimeEngineProtocol
    let dayChangeObserver: DayChangeObserverProtocol
    let taskManager: TaskManagerProtocol

    var dayChangeObservationToken: ObservationToken?

    // MARK: - Properties

    // MARK: State

    enum State {
        case normal
        case editing
    }

    var state: State {
        didSet {
            let editing = state == .editing
//            DispatchQueue.main.sync {
                self.delegate?.setEditButtonTitle(to: self.editButtonTitle)
                self.delegate?.changeEditingState(to: editing)
//            }
            reloadData()
        }
    }

    // MARK: Data

    enum Section: Equatable {
        case incomplete([Row])
        case complete([Row])

        static func == (lhs: Section, rhs: Section) -> Bool {
            switch (lhs, rhs) {
            case (.incomplete, .incomplete):
                return true
            case (.complete, .complete):
                return true
            default:
                return false
            }
        }
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
//                DispatchQueue.main.sync {
                    delegate?.reloadData(with: changes)
//                }
            }
        }
    }

    var newTask: Task? = nil
    var editingTask: Task? = nil

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

        dayChangeObservationToken = self.dayChangeObserver.startObserving { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.reloadData()
            strongSelf.delegate?.setTitle(to: strongSelf.title)
        }

        reloadData()
    }

    deinit {
        if let token = dayChangeObservationToken {
            dayChangeObserver.stopObserving(token)
        }
    }
}

// MARK: Helpers

extension TaskListViewModel {

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

    func rows(in section: Section) -> [Row] {
        if let sectionIndex = index(of: section) {
            return rows(in: sectionIndex)
        } else {
            return []
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

    func index(of section: Section) -> Int? {
        return data.index(of: section)
    }

    func indexPath(of task: Task) -> IndexPath? {
        let section: Int
        if isEditing {
            guard let sectionIndex = self.index(of: .incomplete([])) else { return nil }
            section = sectionIndex
        } else {
            let _section: Int?
            if taskManager.isTaskComplete(task) {
                _section = self.index(of: .complete([]))
            } else {
                _section = self.index(of: .incomplete([]))
            }
            guard let sectionIndex = _section else { return nil }
            section = sectionIndex
        }

        guard let index = self.rows(in: section)
            .flatMap(toTask)
            .index(of: task)
            else { return nil }
        return IndexPath(row: index, section: section)
    }

    func indexPath(of row: Row) -> IndexPath? {
        for (sectionIndex, section) in data.enumerated() {
            if let rowIndex = self.rows(in: section).index(of: row) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
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

    func toggleTaskCompletionStatus(at indexPath: IndexPath) {
        guard !isEditing else { return }
        guard let task = self.task(at: indexPath) else { return }
        let toggledValue = !taskManager.isTaskComplete(task)
        delegate?.updateRowAppearance(toCompleted: toggledValue, at: indexPath, animated: true)
        taskManager.markTask(task, asCompleted: toggledValue)
        if toggledValue {
            delegate?.triggerTaskCompletionFeedback()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reloadData()
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

    func deleteTask(at indexPath: IndexPath) {
        if let task = self.task(at: indexPath) {
            taskManager.deleteTask(task)
            reloadData()
        }
    }
}

// MARK: - Protocol

// MARK: Inputs

extension TaskListViewModel {

    func didSelectRow(at indexPath: IndexPath) {
        if isEditing {
            if indexPathRepresentsNewTaskRow(indexPath) {
                beginCreatingNewTask()
            } else {
                if let currentEditingTask = editingTask,
                    let currentEditingTaskIndexPath = self.indexPath(of: currentEditingTask) {
                    delegate?.updateRowSelectionState(to: false, animated: false, at: currentEditingTaskIndexPath)
                }

                beginEditingTask(at: indexPath)
            }
            delegate?.beginEditingTextView(at: indexPath)
            delegate?.updateRowSelectionState(to: true, animated: true, at: indexPath)
        } else {
            delegate?.updateRowSelectionState(to: false, animated: true, at: indexPath)
            toggleTaskCompletionStatus(at: indexPath)
        }
    }

    func didTapEditButton() {
        toggleEditing()
    }

    func didTapStatusIndicator(at indexPath: IndexPath) {
        toggleTaskCompletionStatus(at: indexPath)
    }

    func didTapDelete(at indexPath: IndexPath) {
        deleteTask(at: indexPath)
    }

    func didBeginEditingText(at indexPath: IndexPath) {
        delegate?.enableInteractionWithTextView(true, at: indexPath)
    }

    func didEndEditingText(at indexPath: IndexPath) {
        delegate?.enableInteractionWithTextView(false, at: indexPath)
    }

    func didTapToDismissKeyboard() {
        delegate?.dismissKeyboard()
    }

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
        if let indexPath = self.indexPath(of: editingTask) {
            delegate?.updateRowSelectionState(to: false, animated: true, at: indexPath)
        }
        self.editingTask = nil
        reloadData()
    }

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

        if let indexPath = indexPath(of: .newEditingTask(newTask.title)) {
            delegate?.updateRowSelectionState(to: false, animated: true, at: indexPath)
            delegate?.clearText(at: indexPath)
        } else if let indexPath = indexPath(of: .newTask) {
            delegate?.updateRowSelectionState(to: false, animated: true, at: indexPath)
            delegate?.clearText(at: indexPath)
        }

        self.newTask = nil
        reloadData()
    }

    func keyboardFrameWillChange(from fromFrame: CGRect, to toFrame: CGRect) {
        let showing = fromFrame.origin.y > toFrame.origin.y
        if showing {
            delegate?.setTaskListBottomInset(to: toFrame.height)
        } else {
            delegate?.setTaskListBottomInset(to: 0)
        }
    }
}

// MARK: Outputs

extension TaskListViewModel {

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

    var editButtonTitle: String {
        if isEditing {
            return "Done"
        } else {
            return "Edit"
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

    func placeholderForTask(at indexPath: IndexPath) -> String {
        if let task = self.task(at: indexPath) {
            return task.title
        } else {
            // TODO: Create a list of placeholders and return a random one
            return "Random placeholder"
        }
    }

    func canEditTextView(at indexPath: IndexPath) -> Bool {
        return isEditing
    }

    func canEditRow(at indexPath: IndexPath) -> Bool {
        guard isEditing else { return false }
        return !indexPathRepresentsNewTaskRow(indexPath)
    }

    func indexPathRepresentsCompletedTask(_ indexPath: IndexPath) -> Bool {
        if let task = self.task(at: indexPath) {
            return taskManager.isTaskComplete(task)
        } else {
            return false
        }
    }

    func indexPathRepresentsEditingTaskRow(_ indexPath: IndexPath) -> Bool {
        guard let editingTask = editingTask else { return false }
        if let task = self.task(at: indexPath) {
            return task.id == editingTask.id
        } else {
            return false
        }
    }

    func indexPathRepresentsNewTaskRow(_ indexPath: IndexPath) -> Bool {
        let row = self.rows(in: indexPath.section)[indexPath.row]
        switch row {
        case .newTask: return true
        case .newEditingTask: return true
        default: return false
        }
    }
}
