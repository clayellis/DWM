//
//  BaseTaskListCell.swift
//  DWM
//
//  Created by Clay Ellis on 12/1/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// TODO: !!! Create a style manager for fonts, images, and colors

// TODO: Add a long press to the cell so that you can directly edit a task without having to tap edit, then select the cell. (Long press, enter edit, begin editing)
// TODO: Add a clear (x) button to NewTaskListCell to delete all text

// Animations:
// MACRO
// INDIVIDUAL ELEMENT ANIMATIONS
// showHighlight(touched: Bool, animated: Bool)
// hideHighlight(animated: Bool)

class BaseTaskListCell: UITableViewCell {

    let highlightArea = UIView()
    let textView = TextView()
    let primaryButton = Button()

    struct Sizes {
        static let highlightAreaOffset: CGFloat = 8
    }

    struct AnimationValues {
        static let highlightScalar: CGFloat = 0.985
        static let highlightedTrueDuration: TimeInterval = 0.2
        static let highlightedFalseDuration: TimeInterval = 0.4
        static let highlightedTranslationX: CGFloat = 2
        static let selectedFalseDuration: TimeInterval = 0.4
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

        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.returnKeyType = .done
    }

    func configureLayout() {
        contentView.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        contentView.addAutoLayoutSubview(highlightArea)
        contentView.addAutoLayoutSubview(primaryButton)
        contentView.addAutoLayoutSubview(textView)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            highlightArea.leftAnchor.constraint(equalTo: contentView.leftMargin, constant: -Sizes.highlightAreaOffset),
            highlightArea.rightAnchor.constraint(equalTo: contentView.rightMargin, constant: Sizes.highlightAreaOffset),
            highlightArea.topAnchor.constraint(equalTo: contentView.topMargin, constant: -Sizes.highlightAreaOffset),
            highlightArea.bottomAnchor.constraint(equalTo: contentView.bottomMargin, constant: Sizes.highlightAreaOffset),

            primaryButton.leftAnchor.constraint(equalTo: contentView.leftMargin),
            primaryButton.centerYAnchor.constraint(equalTo: contentView.centerYMargin),

            textView.leftAnchor.constraint(equalTo: primaryButton.rightAnchor, constant: 15),
            textView.rightAnchor.constraint(equalTo: contentView.rightMargin),
            textView.topAnchor.constraint(equalTo: contentView.topMargin),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomMargin)
            ])
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        primaryButton.removeTarget(nil, action: nil, for: .allEvents)
    }

    // MARK: - Animations

    // TODO: Maybe instead of overriding setHighlighted and setEditing, there should be dedicated methods that I call specifically when
    // the cells should be put in editing mode or highlighted mode. That way the system can't apply the animations in times when it shouldn't.
    // Like in the case where the completeButton jumps because the editing method is called (with `false`) when the cell is reloaded
    // Though, this could be because the animations I'm using to move the views use transforms and the transforms get reset? That's probably it.
    // So I need to fix the animations first (I should have to set the animations up if everything is working correctly)
    // Consider offsetting center and adjust contentScale. Or perhaps do it all by frames.

    // MARK: Highlighted

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            let scalar = AnimationValues.highlightScalar
            let duration = animated ? AnimationValues.highlightedTrueDuration : 0
            let translationX = AnimationValues.highlightedTranslationX
            UIView.animateInParallel(
                highlightArea.animateInParallel(
                    .fadeIn(duration: duration),
                    .scale(by: scalar, duration: duration)
                ),
                textView.animateInParallel(
                    .scale(by: scalar, duration: duration)
                ),
                primaryButton.animateInParallel(
                    .scale(by: scalar, duration: duration),
                    .move(byX: translationX, y: 0, duration: duration)
                )
            )
        } else {
            // Always animate unhighlight
            let duration = AnimationValues.highlightedFalseDuration
            UIView.animateInParallel(
                highlightArea.animateInParallel(
                    .fadeOut(duration: duration),
                    .resetScale(duration: duration)
                ),
                textView.animateInParallel(
                    .resetScale(duration: duration)
                ),
                primaryButton.animateInParallel(
                    .resetScale(),
                    .resetPosition()
                )
            )
        }
    }

    // MARK: Selected

    // TODO: Consider making the selection highlightArea darker than highlight

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            highlightArea.animateInParallel(
                .fadeIn(duration: 0)
            )
        } else {
            let duration = animated ? AnimationValues.selectedFalseDuration : 0
            highlightArea.animateInParallel(
                .fadeOut(duration: duration)
            )
        }
    }

    // MARK: Editing

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

    }

    // MARK: Helpers

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
