//
//  ListsView.swift
//  DWM
//
//  Created by Clay Ellis on 11/17/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

class ListsView: UIView {

    let label = UILabel()

    init() {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        configureSubviews()
        configureLayout()
    }

    private func configureSubviews() {
        backgroundColor = .white
        label.textAlignment = .center
    }

    private func configureLayout() {
        addAutoLayoutSubview(label)
        label.centerInSupervew()
    }
}
