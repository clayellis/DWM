//
//  TaskListNavigationController.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

/// A `UINavigationController` subclass that provides the default navigation bar behavior
/// and styling for a list of tasks
final class TaskListNavigationController: UINavigationController {
    init(taskListController: TaskListViewController) {
        super.init(rootViewController: taskListController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureStyles()
    }

    private func configureStyles() {
        navigationBar.prefersLargeTitles = true
        if let titleLabel = navigationBar.subviewWithClassType(UILabel.self) {
            titleLabel.numberOfLines = 2
            titleLabel.lineBreakMode = .byWordWrapping
        }
        shadowImageView?.isHidden = true
        navigationBar.barTintColor = .white
        navigationBar.backgroundColor = .white
    }
}
