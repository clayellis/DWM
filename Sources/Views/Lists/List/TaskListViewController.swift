//
//  TaskListViewController.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// TODO: Move task to another list
// TODO: (This will be on the carousel level) End editing when swiping between lists
// TODO: Display some sort of fun popup message at midnight (on day changes)
// - "Didn't expect to see you here at this hour! Don't mind me, I'm just renewing your tasks."
// - "What are you doing up this late? Don't mind me..."
// - "Shouldn't you be in bed?"
// ... in order to give some context as to why the list is suddenly refreshing

/// A `UIViewContoller` subclass for presenting a list of tasks
final class TaskListViewController: UIViewController {

    typealias Factory = TaskListFactory & ThemeFactory & FeedbackManagerFactory
    let factory: Factory

    let viewModel: TaskListViewModelProtocol
    let taskListView: TaskListViewProtocol & UIView
    let theme: ThemeProtocol
    let feedbackManager: FeedbackManagerProtocol

    private lazy var newTaskTextViewDelegate = NewTaskTextViewDelegate(controller: self)
    private lazy var editTaskTextViewDelegate = EditTaskTextViewDelegate(controller: self)

    init(factory: Factory, for taskFrequency: TaskFrequency) {
        self.factory = factory
        viewModel = factory.makeTaskListViewModel(for: taskFrequency)
        taskListView = factory.makeTaskListView()
        feedbackManager = factory.makeFeedbackManager()
        theme = factory.makeTheme()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopObservingNotifications()
    }

    override func loadView() {
        view = taskListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configureNavigationBar()
        configureGestureRecognizers()
        configure(tableView: taskListView.tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeNotifications()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopObservingNotifications()
    }

    func configureNavigationBar() {
        title = viewModel.title

        // TODO: Make an edit/done icon
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: viewModel.editButtonTitle,
            style: .plain,
            target: self,
            action: #selector(rightButtonTapped(_:)))
    }

    func configureGestureRecognizers() {
        let tapToDismissGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedToDismissKeyboard(_:)))
        tapToDismissGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapToDismissGestureRecognizer)
    }

    func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    func stopObservingNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Helpers

    func indexPath(from subview: UIView) -> IndexPath? {
        guard let superview = subview.superview else { return nil }
        let point = taskListView.tableView.convert(subview.center, from: superview)
        return taskListView.tableView.indexPathForRow(at: point)
    }

    // TODO: Move to view model
    func didPlaceFingerInTaskRow() {

    }

    // TODO: Move to view model
    func didLiftFingerInTaskRow() {

    }
}

// MARK: View Model Delegate

extension TaskListViewController: TaskListViewModelDelegate {
    func setTitle(to newTitle: String) {
        title = newTitle
    }

    func setEditButtonTitle(to newTitle: String) {
        navigationItem.rightBarButtonItem?.title = newTitle
    }

    func changeEditingState(to editing: Bool) {
        if !editing {
            view.endEditing(true)
        }
        taskListView.tableView.setEditing(editing, animated: true)
    }

    func updateRowSelectionState(to selected: Bool, animated: Bool, at indexPath: IndexPath) {
        if selected {
            taskListView.tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
        } else {
            taskListView.tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    func updateRowAppearance(toCompleted completed: Bool, at indexPath: IndexPath, animated: Bool) {
        guard let cell = taskListView.tableView.cellForRow(at: indexPath) as? TaskListCell else { return }
        cell.setCompleted(completed, animated: animated)
    }

    func reloadData(with changes: Delta.Changes) {
        let tableView = taskListView.tableView
        tableView.performBatchUpdates({
            tableView.deleteRows(at: changes.deletedRows, with: .automatic)
            tableView.insertRows(at: changes.insertedRows, with: .automatic)
            changes.movedRows.forEach { tableView.moveRow(at: $0.from, to: $0.to) }
            changes.deletedSections.forEach { tableView.deleteSections($0, with: .fade) }
            changes.insertedSections.forEach { tableView.insertSections($0, with: .fade) }
        }, completion: { finished in
            // Reload once the animations are complete in order to refresh the section headers and the cell settings
            tableView.reloadData()
        })
    }

    func enableInteractionWithTextView(_ shouldEnable: Bool, at indexPath: IndexPath) {
        guard let cell = taskListView.tableView.cellForRow(at: indexPath) as? BaseTaskListCell else { return }
        cell.textView.isUserInteractionEnabled = shouldEnable
    }

    func clearText(at indexPath: IndexPath) {
        guard let cell = taskListView.tableView.cellForRow(at: indexPath) as? BaseTaskListCell else { return }
        cell.textView.text = ""
    }

    func beginEditingTextView(at indexPath: IndexPath) {
        guard let cell = taskListView.tableView.cellForRow(at: indexPath) as? BaseTaskListCell else { return }
        cell.textView.becomeFirstResponder()
    }

    func dismissKeyboard() {
        view.currentFirstResponder?.resignFirstResponder()
    }

    func triggerTaskCompletionFeedback() {
        feedbackManager.triggerTaskCompletedFeedback()
    }

    func setTaskListBottomInset(to newInset: CGFloat) {
        taskListView.tableView.contentInset.bottom = newInset
    }
}

// MARK: Table View

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func configure(tableView: UITableView) {
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.reuseIdentifier)
        tableView.register(NewTaskListCell.self, forCellReuseIdentifier: NewTaskListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsSelectionDuringEditing = true
        tableView.forceDelaysContentTouches(false)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BaseTaskListCell
        if viewModel.indexPathRepresentsNewTaskRow(indexPath)  {
            let newTaskCell = tableView.dequeueReusableCell(withIdentifier: NewTaskListCell.reuseIdentifier, for: indexPath) as! NewTaskListCell
            cell = newTaskCell
            newTaskCell.textView.delegate = newTaskTextViewDelegate
            newTaskCell.addButton.addTarget(self, action: #selector(cellAddTapped(_:)), for: .touchUpInside)
        } else {
            let taskListCell = tableView.dequeueReusableCell(withIdentifier: TaskListCell.reuseIdentifier, for: indexPath) as! TaskListCell
            cell = taskListCell
            taskListCell.textView.delegate = editTaskTextViewDelegate
            taskListCell.completedButton.addTarget(self, action: #selector(cellCompleteButtonTouchDown(_:)), for: .touchDown)
            taskListCell.completedButton.addTarget(self, action: #selector(cellCompleteButtonTapped(_:)), for: .touchUpInside)
            taskListCell.deleteButton.addTarget(self, action: #selector(cellDeleteTapped(_:)), for: .touchUpInside)
            let isCompleted = viewModel.indexPathRepresentsCompletedTask(indexPath)
            taskListCell.setCompleted(isCompleted, animated: false)
        }

        // Set values
        cell.textView.text = viewModel.titleForTask(at: indexPath)
        cell.textView.placeholder = viewModel.placeholderForTask(at: indexPath)
        cell.textView.isEditable = viewModel.canEditTextView(at: indexPath)
        // TODO: Find a way to not have to do this here (rather in the delegate method)
        cell.textView.isUserInteractionEnabled = false

        return cell
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        didPlaceFingerInTaskRow()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
        didLiftFingerInTaskRow()
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.canEditRow(at: indexPath)
    }
}

// MARK: Selectors

extension TaskListViewController {

    @objc func keyboardWillChange(_ notification: NSNotification) {
        guard let keyboardBeginFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue,
            let keyboardEndFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            else { return }
        viewModel.keyboardFrameWillChange(from: keyboardBeginFrame, to: keyboardEndFrame)
    }

    @objc func rightButtonTapped(_ button: UIBarButtonItem) {
        viewModel.didTapEditButton()
    }

    @objc func tappedToDismissKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        viewModel.didTapToDismissKeyboard()
    }

    @objc func cellCompleteButtonTouchDown(_ button: UIButton) {
        didPlaceFingerInTaskRow()
    }

    @objc func cellCompleteButtonTapped(_ button: UIButton) {
        guard let indexPath = self.indexPath(from: button) else { return }
        viewModel.didTapCompleteButton(at: indexPath)
        didLiftFingerInTaskRow()
    }

    @objc func cellDeleteTapped(_ button: UIButton) {
        guard let indexPath = self.indexPath(from: button) else { return }
        // TODO: Present some sort of confirmation (in row, action sheet...)
        viewModel.didTapDelete(at: indexPath)
    }

    @objc func cellAddTapped(_ button: UIButton) {
        guard let indexPath = self.indexPath(from: button) else { return }
        viewModel.didTapAdd(at: indexPath)
    }
}

// MARK: Text View

private class TextViewDelegate: NSObject, UITextViewDelegate {
    weak var controller: TaskListViewController?

    init(controller: TaskListViewController) {
        self.controller = controller
        super.init()
    }

    // TODO: Consider disabling user interaction on the text view (so that the only way to start editing is to select the row)
    // And once editing begins, enable interaction, once editing ends, disable interaction

    func textViewDidBeginEditing(_ textView: UITextView) {
        if let indexPath = controller?.indexPath(from: textView) {
            controller?.viewModel.didBeginEditingText(at: indexPath)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        // If the number of lines change (if the currentHeight != the contentHeight)
        // then the textView should grow/shrink.
        let currentHeight = textView.frame.size.height
        let contentHeight = textView.intrinsicContentSize.height
        if currentHeight != contentHeight {
            // Grow/shrink the textView by toggling updates on the tableView.
            // Toggle animationsEnabled in order to avoid some jumpiness when
            // toggling updates on the tableView.
            UIView.setAnimationsEnabled(false)
            controller?.taskListView.tableView.beginUpdates()
            controller?.taskListView.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if let indexPath = controller?.indexPath(from: textView) {
            controller?.viewModel.didEndEditingText(at: indexPath)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        } else {
            return true
        }
    }
}

// FIXME: There was a case once where a word auto corrected in the label, but the editingTask wasn't updated, so when done was tapped, the uncorrected word was displayed

private final class NewTaskTextViewDelegate: TextViewDelegate {
    override func textViewDidBeginEditing(_ textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        controller?.viewModel.beginCreatingNewTask()
    }

    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        controller?.viewModel.updateNewTask(title: textView.text)
    }

    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        controller?.viewModel.commitNewTask()
    }
}

private final class EditTaskTextViewDelegate: TextViewDelegate {
    override func textViewDidBeginEditing(_ textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        guard let indexPath = controller?.indexPath(from: textView) else { return }
        controller?.viewModel.beginEditingTask(at: indexPath)
    }

    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        controller?.viewModel.updateEditingTask(title: textView.text)
    }

    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        controller?.viewModel.commitEditingTask()
    }
}

// MARK: Gesture Recognizer

extension TaskListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: taskListView.tableView)
        for cell in taskListView.tableView.visibleCells {
            if cell.frame.contains(touchPoint) {
                return false
            }
        }
        return true
    }
}
