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

/// A `UIViewContoller` subclass for presenting a list of tasks
final class TaskListViewController: UIViewController {

    typealias Factory = TaskListFactory
    let factory: Factory

    let viewModel: TaskListViewModelProtocol
    let taskListView: TaskListViewProtocol & UIView

    private lazy var newTaskTextViewDelegate = NewTaskTextViewDelegate(controller: self)
    private lazy var editTaskTextViewDelegate = EditTaskTextViewDelegate(controller: self)

    init(factory: Factory, for taskFrequency: TaskFrequency) {
        self.factory = factory
        self.viewModel = factory.makeTaskListViewModel(for: taskFrequency)
        self.taskListView = factory.makeTaskListView()
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
        configureNavigationBar()
        configureGestureRecognizers()
        configure(tableView: taskListView.tableView)
        observeViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingNotifications()
    }

    func configureNavigationBar() {
        title = viewModel.title

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

    func observeViewModel() {
        viewModel.dataDidChange = { [weak self] changes in
            if let tableView = self?.taskListView.tableView {
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: changes.deletedRows, with: .automatic)
                    tableView.insertRows(at: changes.insertedRows, with: .automatic)
                    changes.movedRows.forEach { tableView.moveRow(at: $0.from, to: $0.to) }
                    changes.deletedSections.forEach { tableView.deleteSections($0, with: .fade) }
                    changes.insertedSections.forEach { tableView.insertSections($0, with: .fade) }
                    // FIXME: Reload the complete section header title without having to reload the entire section
                    // If you reload the section, you lose the animation
                }, completion: nil)
            }
        }

        viewModel.editingStateDidChange = { [weak self] editing in
            if let rightButton = self?.navigationItem.rightBarButtonItem {
                rightButton.title = self?.viewModel.editButtonTitle
            }
            self?.taskListView.tableView.setEditing(editing, animated: true)
        }

        viewModel.didBeginEditing = { [weak self] indexPath in
            if let cell = self?.taskListView.tableView.cellForRow(at: indexPath) as? TaskListCell {
                cell.textView.becomeFirstResponder()
            }
        }
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
}

// MARK: Selectors

extension TaskListViewController {

    @objc func keyboardWillChange(_ notification: NSNotification) {
        guard let keyboardBeginFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue,
            let keyboardEndFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            else { return }
        let showing = keyboardBeginFrame.origin.y > keyboardEndFrame.origin.y
        if showing {
            taskListView.tableView.contentInset.bottom = keyboardEndFrame.height
        } else {
            taskListView.tableView.contentInset.bottom = 0
        }
    }

    @objc func rightButtonTapped(_ button: UIBarButtonItem) {
        viewModel.commitNewTask()
        viewModel.commitEditingTask()
        viewModel.toggleEditing()
    }

    @objc func tappedToDismissKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: Table View

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func configure(tableView: UITableView) {
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskListCell.reuseIdentifier, for: indexPath) as! TaskListCell
        cell.textView.text = viewModel.titleForTask(at: indexPath)
        cell.textView.isEditable = viewModel.isEditingEnabled
        cell.textView.isUserInteractionEnabled = viewModel.isEditingEnabled
        if viewModel.indexPathRepresentsNewTaskRow(indexPath) {
            cell.textView.delegate = newTaskTextViewDelegate
        } else {
            cell.textView.delegate = editTaskTextViewDelegate
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectedRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard viewModel.isEditingEnabled else { return .none }

        if viewModel.indexPathRepresentsNewTaskRow(indexPath) {
            return .none
        } else {
            return .delete
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard viewModel.isEditingEnabled else { return false }
        return !viewModel.indexPathRepresentsNewTaskRow(indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.deleteTask(at: indexPath)
    }
}

// MARK: Text View

private class TextViewDelegate: NSObject, UITextViewDelegate {
    weak var controller: TaskListViewController?

    init(controller: TaskListViewController) {
        self.controller = controller
        super.init()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {}

    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {}

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
        controller?.viewModel.beginCreatingNewTask()
    }

    override func textViewDidChange(_ textView: UITextView) {
        controller?.viewModel.updateNewTask(title: textView.text)
    }

    override func textViewDidEndEditing(_ textView: UITextView) {
        controller?.viewModel.commitNewTask()
    }
}

private final class EditTaskTextViewDelegate: TextViewDelegate {
    override func textViewDidBeginEditing(_ textView: UITextView) {
        guard let indexPath = controller?.indexPath(from: textView) else { return }
        controller?.viewModel.beginEditingTask(at: indexPath)
    }

    override func textViewDidChange(_ textView: UITextView) {
        controller?.viewModel.updateEditingTask(title: textView.text)
    }

    override func textViewDidEndEditing(_ textView: UITextView) {
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
