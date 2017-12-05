//
//  NewTaskListCell.swift
//  DWM
//
//  Created by Clay Ellis on 12/1/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// TODO: What should happen when a user starts entering a new task and then decides they don't want it? Should we display a cancel (delete) button?
// We could just treat it like a normal cell once the user starts editing, but before they do start editing, display a plus
// If we do it that way though, we need to display a new "plus" row below the current new editing row once the user starts typing something in

final class NewTaskListCell: BaseTaskListCell {

    var addButton: Button {
        return primaryButton
    }

    override func configureSubviews() {
        super.configureSubviews()
        addButton.setImage(#imageLiteral(resourceName: "AddNormal"), for: .normal)
        addButton.setImage(#imageLiteral(resourceName: "AddHighlighted"), for: .highlighted)
        addButton.adjustsImageWhenHighlighted = false
        addButton.contentMode = .center
    }

    override func configureLayout() {
        super.configureLayout()

    }

    // MARK: - Animations

    // MARK: Highlighted

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }

    // MARK: Selected

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Editing

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
//        let duration: TimeInterval = animated ? 0.15 : 0
        if editing {
//            addButton.alpha = 0
//            textView.alpha = 0
//            UIView.animateInParallel(
//                addButton.animate(.fadeIn(duration: 5)),
//                textView.animate(.fadeIn(duration: 5))
//            )
            contentView.alpha = 0
            UIView.animateInParallel(
                contentView.animate(.fadeIn(duration: 5))
            )
        } else {
//            UIView.animateInParallel(
//                addButton.animate(.fadeOut(duration: 0.15)),
//                textView.animate(.fadeOut(duration: 0.15))
//            )
            UIView.animateInParallel(
                contentView.animate(.fadeOut(duration: 0.15))
            )
        }

    }
}
