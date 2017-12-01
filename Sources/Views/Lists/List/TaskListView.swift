//
//  TaskListView.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// Just stick to white for now (add complexity later if it looks good)
// TODO: Add a slight fade gradient at the top (under the navigation bar) (if nav bar is white, otherwise, just use a hard edge)
// TODO: Add a slight fade gradient at the bottom of the table view (to fade cells as they move off) (if we do end up making the done section gray, use a gray fade, otherwise white)

protocol TaskListViewProtocol {
    var tableView: UITableView { get }
}

final class TaskListView: UIView, TaskListViewProtocol {

    let tableView = UITableView(frame: .zero, style: .grouped)
    let bottomFade = FadeView(direction: .up)

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
        bottomFade.color = .white
    }

    func configureLayout() {
        addAutoLayoutSubview(tableView)
        addAutoLayoutSubview(bottomFade)
        tableView.fillSuperview()
        NSLayoutConstraint.activate([
            bottomFade.leftAnchor.constraint(equalTo: leftAnchor),
            bottomFade.rightAnchor.constraint(equalTo: rightAnchor),
            bottomFade.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomFade.heightAnchor.constraint(equalToConstant: 5)
            ])
    }
}
