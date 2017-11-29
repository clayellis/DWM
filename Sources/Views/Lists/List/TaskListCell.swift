//
//  TaskListCell.swift
//  DWM
//
//  Created by Clay Ellis on 11/21/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// TODO: Create a subclass NewTaskListCell that hides the status indicator
// TODO: Add a clear (x) button to NewTaskListCell to delete all text

// TODO: Add a placeholder to the textView
// TODO: Add custom delete button that replaces the status indicator while editing

// TODO: Create a style manager for fonts, images, and colors

class TaskListCell: UITableViewCell {

    let textView = UITextView()
    let statusIndicator = UIButton()
    let deleteButton = UIButton()
    let highlightArea = UIView()

    // FIXME: Remove state, there should be a better way to accomplish this
    private var styledAsCompleted: Bool = false

    struct Sizes {
        static let statusIndicatorDiameter: CGFloat = 17
        static var statusIndicatorRadius: CGFloat {
            return statusIndicatorDiameter / 2
        }
        static let highlightAreaMargin: CGFloat = 8
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureSubviews() {
        selectionStyle = .none

        highlightArea.backgroundColor = UIColor(hexString: "F4F4F4")
        highlightArea.layer.cornerRadius = 10

        statusIndicator.layer.borderWidth = 2
        statusIndicator.layer.masksToBounds = true
        statusIndicator.layer.cornerRadius = Sizes.statusIndicatorRadius
        statusIndicator.setBackgroundColor(UIColor.clear, forUIControlState: .normal)
        statusIndicator.setBackgroundColor(UIColor.black.withAlphaComponent(0.1), forUIControlState: [.normal, .highlighted])
        statusIndicator.setBackgroundColor(UIColor.black.withAlphaComponent(0.2), forUIControlState: .selected)
        statusIndicator.setBackgroundColor(UIColor.black.withAlphaComponent(0.1), forUIControlState: [.selected, .highlighted])

        // TODO: Increase the size of the delete image
        // TODO: Increase the hit target area for delete button and status indicator (so that their frames are at least 44x44)
        deleteButton.setImage(#imageLiteral(resourceName: "Delete"), for: .normal)
        deleteButton.adjustsImageWhenHighlighted = false
        deleteButton.alpha = 0

        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.returnKeyType = .done
    }

    func configureLayout() {
        contentView.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        contentView.addAutoLayoutSubview(highlightArea)
        contentView.addAutoLayoutSubview(statusIndicator)
        contentView.addAutoLayoutSubview(deleteButton)
        contentView.addAutoLayoutSubview(textView)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            highlightArea.leftAnchor.constraint(equalTo: contentView.leftMargin, constant: -Sizes.highlightAreaMargin),
            highlightArea.rightAnchor.constraint(equalTo: contentView.rightMargin, constant: Sizes.highlightAreaMargin),
            highlightArea.topAnchor.constraint(equalTo: contentView.topMargin, constant: -Sizes.highlightAreaMargin),
            highlightArea.bottomAnchor.constraint(equalTo: contentView.bottomMargin, constant: Sizes.highlightAreaMargin),

            statusIndicator.leftAnchor.constraint(equalTo: contentView.leftMargin),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYMargin),
            statusIndicator.widthAnchor.constraint(equalToConstant: Sizes.statusIndicatorDiameter),
            statusIndicator.heightAnchor.constraint(equalTo: statusIndicator.widthAnchor),

            deleteButton.leftAnchor.constraint(equalTo: statusIndicator.leftAnchor),
            deleteButton.rightAnchor.constraint(equalTo: statusIndicator.rightAnchor),
            deleteButton.topAnchor.constraint(equalTo: statusIndicator.topAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: statusIndicator.bottomAnchor),

            textView.leftAnchor.constraint(equalTo: statusIndicator.rightAnchor, constant: 10),
            textView.rightAnchor.constraint(equalTo: contentView.rightMargin),
            textView.topAnchor.constraint(equalTo: contentView.topMargin),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomMargin)
            ])
    }

    func toggleStyling() {
        let toggledValue = !styledAsCompleted
        applyStyling(asComplete: toggledValue)
    }

    func applyStyling(asComplete complete: Bool) {
        defer { styledAsCompleted = complete }

        crossDisolve(on: statusIndicator) {
            if complete {
                self.statusIndicator.isSelected = true
                self.textView.textColor = UIColor.black.withAlphaComponent(0.2)
            } else {
                self.statusIndicator.isSelected = false
                self.textView.textColor = .black
            }
        }

        animateChanges {
            if complete {
//                self.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.01)
                self.statusIndicator.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            } else {
//                self.contentView.backgroundColor = .white
                self.statusIndicator.layer.borderColor = UIColor.black.cgColor
            }
        }
    }

    func animateChanges(duration: TimeInterval = 0.15, _ animations: @escaping () -> ()) {
        // TODO: Consider using new animation API
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut],
                       animations: animations,
                       completion: nil)
    }

    func crossDisolve(changes animations: @autoclosure @escaping () -> (), on view: UIView) {
        UIView.transition(with: view,
                          duration: 0.15,
                          options: [.beginFromCurrentState, .allowUserInteraction, .transitionCrossDissolve],
                          animations: animations,
                          completion: nil)
    }

    func crossDisolve(on view: UIView, _ animations: @escaping () -> ()) {
        self.crossDisolve(changes: animations(), on: view)
    }
}

// MARK: Highlight

extension TaskListCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            let scalar: CGFloat = 0.985
            let duration: TimeInterval = 0.2
            UIView.animateInParallel(
                highlightArea.animateInParallel(
                    .fadeIn(duration: duration),
                    .scale(by: scalar, duration: duration)
                ),
                statusIndicator.animateInParallel(
                    .scale(by: scalar, duration: duration),
                    .move(byX: 2, y: 0, duration: duration)
                ),
                textView.animateInParallel(
                    .scale(by: scalar, duration: duration)
                )
            )
        } else {
            let duration: TimeInterval = 0.4
            UIView.animateInParallel(
                highlightArea.animateInParallel(
                    .fadeOut(duration: duration),
                    .resetScale(duration: duration)
                ),
                statusIndicator.animateInParallel(
                    .resetScale(duration: duration),
                    .resetPosition(duration: duration)
                ),
                textView.animateInParallel(
                    .resetScale(duration: duration)
                )
            )
        }

//        crossDisolve(changes: self.statusIndicator.isHighlighted = highlighted, on: statusIndicator)
    }
}

// MARK: Edit

extension TaskListCell {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let transformValue: CGFloat = -10
        let duration: TimeInterval = animated ? 0.15 : 0
        if editing {
            UIView.animate(
                statusIndicator.animateInParallel(
                    .fadeOut(duration: duration),
                    .move(byX: transformValue, y: 0, duration: duration)
                ),
                deleteButton.animateInParallel(
                    .fadeIn(duration: duration),
                    .resetPosition(duration: duration)
                )
            )
        } else {
            statusIndicator.transform.tx = transformValue
            UIView.animate(
                deleteButton.animateInParallel(
                    .fadeOut(duration: duration),
                    .move(byX: transformValue, y: 0, duration: duration)
                ),
                statusIndicator.animateInParallel(
                    .fadeIn(duration: duration),
                    .resetPosition(duration: duration)
                )
            )
        }
    }
}

final class NewTaskListCell: TaskListCell {
    override func configureSubviews() {
        super.configureSubviews()
        statusIndicator.isHidden = true
    }

    override func configureLayout() {
        super.configureLayout()

    }
}
