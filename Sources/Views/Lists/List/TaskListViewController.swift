//
//  TaskListViewController.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// TODO: Adjust content inset bottom when keyboard shows
// TODO: Scroll to row that's being edited so that it doesn't sit behind the keyboard
// TODO: Delete task
// TODO: Move task to another list

// TODO: When you enter edit mode, there should only be one section (not incomplete and complete)

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

    override func loadView() {
        view = taskListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure(tableView: taskListView.tableView)
        observeViewModel()
    }

    func configureNavigationBar() {
        title = viewModel.title

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: viewModel.editButtonTitle,
            style: .plain,
            target: self,
            action: #selector(rightButtonTapped(_:)))
    }

    func observeViewModel() {
        viewModel.dataDidChange = { [weak self] in
            self?.taskListView.tableView.reloadData()
        }

        viewModel.editingStateDidChange = { [weak self] editing in
            guard let rightButton = self?.navigationItem.rightBarButtonItem else { return }
            rightButton.title = self?.viewModel.editButtonTitle
        }

        viewModel.didBeginEditing = { [weak self] indexPath in
            guard let cell = self?.taskListView.tableView.cellForRow(at: indexPath) as? TaskListCell else { return }
            cell.textView.becomeFirstResponder()
        }
    }

    @objc func rightButtonTapped(_ button: UIBarButtonItem) {
        viewModel.toggleEditing()
    }

    func indexPath(from subview: UIView) -> IndexPath? {
        guard let superview = subview.superview else { return nil }
        let point = taskListView.tableView.convert(subview.center, from: superview)
        return taskListView.tableView.indexPathForRow(at: point)
    }
}

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
}

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
