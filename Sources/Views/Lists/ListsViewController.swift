//
//  ListsViewController.swift
//  DWM
//
//  Created by Clay Ellis on 11/17/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController {

    let listsView = ListsView()

    override func loadView() {
        view = listsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listsView.label.text = "Lists"
    }
}
