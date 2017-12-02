//
//  TaskListCell.swift
//  DWM
//
//  Created by Clay Ellis on 11/21/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

final class TaskListCell: BaseTaskListCell {

    var completedButton: Button {
        return primaryButton
    }
    let deleteButton = Button()

    struct Sizes {
        static let completedButtonDiameter: CGFloat = 17
        static var completedButtonRadius: CGFloat {
            return completedButtonDiameter / 2
        }
    }

    override func configureSubviews() {
        super.configureSubviews()
        completedButton.layer.borderWidth = 2
        completedButton.layer.masksToBounds = true
        completedButton.layer.cornerRadius = Sizes.completedButtonRadius
        completedButton.setBackgroundColor(UIColor.clear, forUIControlState: .normal)
        completedButton.setBackgroundColor(UIColor.black.withAlphaComponent(0.1), forUIControlState: [.normal, .highlighted])
        completedButton.setBackgroundColor(UIColor.black.withAlphaComponent(0.2), forUIControlState: .selected)
        completedButton.setBackgroundColor(UIColor.black.withAlphaComponent(0.1), forUIControlState: [.selected, .highlighted])

        deleteButton.setImage(#imageLiteral(resourceName: "DeleteNormal"), for: .normal)
        deleteButton.setImage(#imageLiteral(resourceName: "DeleteHighlighted"), for: .highlighted)
        deleteButton.adjustsImageWhenHighlighted = false
        deleteButton.alpha = 0
        deleteButton.contentMode = .center
    }

    override func configureLayout() {
        super.configureLayout()
        contentView.addAutoLayoutSubview(deleteButton)
        NSLayoutConstraint.activate([
            completedButton.widthAnchor.constraint(equalToConstant: Sizes.completedButtonDiameter),
            completedButton.heightAnchor.constraint(equalTo: completedButton.widthAnchor),

            deleteButton.centerYAnchor.constraint(equalTo: completedButton.centerYAnchor),
            deleteButton.centerXAnchor.constraint(equalTo: completedButton.centerXAnchor),
            ])
    }

    // MARK: - Animations

    // MARK: Completed

    override func setCompleted(_ completed: Bool, animated: Bool) {
        super.setCompleted(completed, animated: animated)
        crossDisolve(on: completedButton) {
            if completed {
                self.completedButton.isSelected = true
            } else {
                self.completedButton.isSelected = false
            }
        }

        animateChanges {
            if completed {
                self.completedButton.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            } else {
                self.completedButton.layer.borderColor = UIColor.black.cgColor
            }
        }
    }

    // MARK: Highlighted

    // ANIMATION:
    // On down, the status indicator (and title) shrinks slightly on a spring (like it's being pressed down and loaded to spring)
    // and the first stroke of the check mark is drawn going down

    // ANIMATION:
    // On the up movement, the status indicator (and title) springs up past its normal size and shakes (rotationally) with excitement just slightly (not the title)
    // and the final upwward stroke of the check mark is drawn
    // The indicator glows a certain color and pulses that color outwards

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            let scalar = AnimationValues.highlightScalar
            let duration = AnimationValues.highlightedTrueDuration
            let translationX = AnimationValues.highlightedTranslationX
            UIView.animateInParallel(
                deleteButton.animateInParallel(
                    .scale(by: scalar, duration: duration),
                    .move(byX: translationX, y: 0, duration: duration)
                )
            )
        } else {
            let duration: TimeInterval = AnimationValues.highlightedFalseDuration
            let translationX = -AnimationValues.highlightedTranslationX
            UIView.animateInParallel(
                completedButton.animateInParallel(
                    .resetScale(duration: duration),
                    .move(byX: translationX, y: 0, duration: duration)
                )
            )
        }

//        crossDisolve(changes: self.completedButton.isHighlighted = highlighted, on: completedButton)
    }

    // MARK: Selected


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    // MARK: Editing

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let transformValue: CGFloat = -10
        let duration: TimeInterval = animated ? 0.15 : 0
        if editing {
            UIView.animate(
                completedButton.animateInParallel(
                    .fadeOut(duration: duration),
                    .move(byX: transformValue, y: 0, duration: duration)
                ),
                deleteButton.animateInParallel(
                    .fadeIn(duration: duration),
                    .move(byX: -transformValue, y: 0, duration: duration)
                )
            )
            //            UIView.animate(
            //                textView.animate(
            //                    .move(byX: transformValue, y: 0, duration: duration),
            //                    .resetPosition(duration: duration)
            //                )
            //            )
        } else {
            // FIXME: setEditing is being called when the cell is selected/highlighted
            // (for instance, after a user taps a task to complete it)
            // and the status indicator is moving when it shouldn't.

            //            completedButton.transform.tx = transformValue
            UIView.animate(
                deleteButton.animateInParallel(
                    .fadeOut(duration: duration),
                    .move(byX: transformValue, y: 0, duration: duration)
                ),
                completedButton.animateInParallel(
                    .fadeIn(duration: duration),
                    .move(byX: -transformValue, y: 0, duration: duration)
                )
            )
            //            UIView.animate(
            //                textView.animate(
            //                    .move(byX: transformValue, y: 0, duration: duration),
            //                    .resetPosition(duration: duration)
            //                )
            //            )
        }
    }
}
