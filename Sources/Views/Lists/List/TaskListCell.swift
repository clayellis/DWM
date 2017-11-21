//
//  TaskListCell.swift
//  DWM
//
//  Created by Clay Ellis on 11/21/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

class TaskListCell: UITableViewCell {

    let textView = UITextView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureSubviews() {
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.returnKeyType = .done
    }

    func configureLayout() {
        contentView.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        contentView.addAutoLayoutSubview(textView)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.fillSuperviewLayoutMargins()
    }
}
