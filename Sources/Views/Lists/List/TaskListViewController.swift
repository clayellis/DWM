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

    typealias Factory = TaskListFactory & ThemeFactory
    let factory: Factory

    let viewModel: TaskListViewModelProtocol
    let taskListView: TaskListViewProtocol & UIView
    let theme: ThemeProtocol

    private lazy var newTaskTextViewDelegate = NewTaskTextViewDelegate(controller: self)
    private lazy var editTaskTextViewDelegate = EditTaskTextViewDelegate(controller: self)

    init(factory: Factory, for taskFrequency: TaskFrequency) {
        self.factory = factory
        self.viewModel = factory.makeTaskListViewModel(for: taskFrequency)
        self.taskListView = factory.makeTaskListView()
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
        configureNavigationBar()
        configureGestureRecognizers()
        configure(tableView: taskListView.tableView)
        observeViewModel()
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
        viewModel.titleShouldReload = { [weak self] in
            self?.title = self?.viewModel.title
        }

        viewModel.dataDidChange = { [weak self] changes in
            if let tableView = self?.taskListView.tableView {
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: changes.deletedRows, with: .automatic)
                    tableView.insertRows(at: changes.insertedRows, with: .automatic)
                    // TODO: Before moving rows to their new IndexPath, apply the appropriate styling (complete/incomplete)
                    // TODO: After styling animation completes, move the rows.
                    // If movedRows is the only non-empty item in changes, apply the styling outside of performBatchUpdates
                    // and then move the rows (using performBatchUpdates), in applyStyling's completion handler
                    changes.movedRows.forEach { tableView.moveRow(at: $0.from, to: $0.to) }
//                    for move in changes.movedRows {
//                        tableView.deleteRows(at: [move.from], with: UITableViewRowAnimation.fade)
//                        tableView.insertRows(at: [move.to], with: UITableViewRowAnimation.fade)
//                    }

                    changes.deletedSections.forEach { tableView.deleteSections($0, with: .fade) }
                    changes.insertedSections.forEach { tableView.insertSections($0, with: .fade) }
                }, completion: { finished in
                    // Reload once the animations are complete in order to refresh the section headers and the cell settings
                    tableView.reloadData()
                })
            }
        }

        viewModel.editingStateDidChange = { [weak self] editing in
            if !editing {
                self?.view.endEditing(true)
            }
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
        viewModel.toggleEditing()
    }

    @objc func tappedToDismissKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc func cellStatusIndicatorTapped(_ button: UIButton) {
        guard let indexPath = self.indexPath(from: button) else { return }
        viewModel.toggleTaskCompletionStatus(at: indexPath)
    }
}

// MARK: Table View

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func configure(tableView: UITableView) {
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.reuseIdentifier)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskListCell.reuseIdentifier, for: indexPath) as! TaskListCell
        cell.statusIndicator.addTarget(self, action: #selector(cellStatusIndicatorTapped(_:)), for: .touchUpInside)
        cell.textView.text = viewModel.titleForTask(at: indexPath)
        cell.textView.isEditable = viewModel.isEditingEnabled
        cell.textView.isUserInteractionEnabled = viewModel.isEditingEnabled
        if viewModel.indexPathRepresentsNewTaskRow(indexPath) {
            cell.textView.delegate = newTaskTextViewDelegate
        } else {
            cell.textView.delegate = editTaskTextViewDelegate
        }
        cell.applyStyling(asComplete: viewModel.isTaskComplete(at: indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? TaskListCell {

            // TODO: Use completion blocks instead of asyncAfter
            cell.toggleStyling()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.viewModel.selectedRow(at: indexPath)
            }
        } else {
            viewModel.selectedRow(at: indexPath)
        }
//        if let cell = tableView.cellForRow(at: indexPath) as? TaskListCell {
//            cell.toggleStyling(completion: {
//                self.viewModel.selectedRow(at: indexPath)
//            })
//        } else {
//            viewModel.selectedRow(at: indexPath)
//        }
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
        textView.text = ""
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
