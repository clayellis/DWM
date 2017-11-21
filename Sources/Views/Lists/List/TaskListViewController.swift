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
    let listView: TaskListViewProtocol & UIView

    init(factory: Factory, for taskFrequency: TaskFrequency) {
        self.factory = factory
        self.viewModel = factory.makeTaskListViewModel(for: taskFrequency)
        self.listView = factory.makeTaskListView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = listView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure(tableView: listView.tableView)
        observeViewModel()
    }

    func configureNavigationBar() {
        title = viewModel.title
    }

    func observeViewModel() {
        viewModel.dataDidChange = { [weak self] in
            self?.listView.tableView.reloadData()
        }
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func configure(tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTasks(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = viewModel.titleForTask(at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.toggleTaskCompletionStatus(at: indexPath)
    }
}
