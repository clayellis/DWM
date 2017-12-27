//
//  TaskListView.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// TODO: In long lists, tapping edit doesn't show the "new task" cell because it's clear at the bottom.
// Instead of scrolling to it, we should display a stand-in over the table view, at the bottom.

protocol TaskListViewProtocol {
    var tableView: UITableView { get }
//    var standIn: UIButton { get }
}

final class TaskListView: UIView, TaskListViewProtocol {

    let tableView = UITableView(frame: .zero, style: .grouped)
//    let bottomFade = FadeView(direction: .up)
//    private let fakeCell = NewTaskListCell(style: .default, reuseIdentifier: "FAKE CELL")
//    let standIn = UIButton()

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
        tableView.showsVerticalScrollIndicator = false
//        bottomFade.color = .white
//        standIn.backgroundColor = UIColor.red.withAlphaComponent(0.4)

//        fakeCell.configureSubviews()
//        fakeCell.configureLayout()
//        fakeCell.contentView.alpha = 1
//        fakeCell.isHidden = false
//        fakeCell.backgroundColor = UIColor.green.withAlphaComponent(0.5)
//        fakeCell.textView.alpha = 1
//        fakeCell.textView.placeholder = "FAKE CELL"
    }

    func configureLayout() {
        addAutoLayoutSubview(tableView)
//        addAutoLayoutSubview(standIn)
//        addAutoLayoutSubview(fakeCell)
//        fakeCell.addAutoLayoutSubview(standIn)

        tableView.fillSuperview()

//        addAutoLayoutSubview(bottomFade)
//        NSLayoutConstraint.activate([
//            bottomFade.leftAnchor.constraint(equalTo: leftAnchor),
//            bottomFade.rightAnchor.constraint(equalTo: rightAnchor),
//            bottomFade.bottomAnchor.constraint(equalTo: bottomAnchor),
//            bottomFade.heightAnchor.constraint(equalToConstant: 5)
//            ])

//        standIn.fillSuperview()
//        NSLayoutConstraint.activate([
//            fakeCell.leftAnchor.constraint(equalTo: leftAnchor),//, priority: .defaultHigh),
//            fakeCell.rightAnchor.constraint(equalTo: rightAnchor),//, priority: .defaultHigh),
//            fakeCell.bottomAnchor.constraint(equalTo: bottomAnchor),//, priority: .defaultHigh),
//            fakeCell.heightAnchor.constraint(equalToConstant: 55)//, priority: .defaultHigh)
//            ])
    }
}
