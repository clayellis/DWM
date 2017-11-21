//
//  TaskListViewController.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

/// A `UIViewContoller` subclass for presenting a list of tasks
final class TaskListViewController: UIViewController {

    typealias Factory = TaskListFactory
    let factory: Factory

    let viewModel: TaskListViewModelProtocol
    let taskListView: TaskListViewProtocol & UIView

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

        viewModel.editingDidChange = { [weak self] editing in
            guard let rightButton = self?.navigationItem.rightBarButtonItem else { return }
            rightButton.title = self?.viewModel.editButtonTitle
        }
    }

    @objc func rightButtonTapped(_ button: UIBarButtonItem) {
        viewModel.toggleEditing()
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func configure(tableView: UITableView) {
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
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
        cell.textView.delegate = self
        cell.textView.text = viewModel.titleForTask(at: indexPath)
        if viewModel.indexPathRepresentsNewTaskRow(indexPath) {
            cell.textView.isEditable = true
            cell.textView.isUserInteractionEnabled = true
        } else {
            cell.textView.isEditable = false
            cell.textView.isUserInteractionEnabled = false
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? TaskListCell else { return }
        if viewModel.indexPathRepresentsNewTaskRow(indexPath) {
            cell.textView.becomeFirstResponder()
        } else {
            viewModel.toggleTaskCompletionStatus(at: indexPath)
        }
    }
}

extension TaskListViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewModel.beginCreatingNewTask()
    }

    func textViewDidChange(_ textView: UITextView) {
        viewModel.updateNewTask(title: textView.text)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.commitNewTask()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            endEditing()
            return false
        } else {
            return true
        }
    }

    func endEditing() {
        view.endEditing(true)
    }
}
