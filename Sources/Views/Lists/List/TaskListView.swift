//
//  TaskListView.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

protocol TaskListViewProtocol {
    var tableView: UITableView { get }
}

final class TaskListView: UIView, TaskListViewProtocol {

    let tableView = UITableView(frame: .zero, style: .grouped)

    init() {
        super.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureSubviews() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
    }

    func configureLayout() {
        addAutoLayoutSubview(tableView)
        tableView.fillSuperview()
    }
}
