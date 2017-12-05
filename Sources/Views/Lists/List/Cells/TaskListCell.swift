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

    // TODO: prepareSetCompleted(_ completed: Bool, animated: Bool)
    // Basically setHighlighted, but only called when the view is not in edit mode
    // ANIMATION:
    // On down, the complete button (and title) shrinks slightly on a spring (like it's being pressed down and loaded to spring)
    // and the first stroke of the check mark is drawn going down

    // FIXME: I've seen ghosting when scrolling quickly through a long list of cells where the content of a reused cell
    // was visible for a second because the textview was being cross dissolved. By using an animated flag we can set the animation duration to 0.

    func setCompleted(_ completed: Bool, animated: Bool) {

        // ANIMATION:
        // On the up movement, the complete button (and title) springs up past its normal size and shakes (rotationally) with excitement just slightly (not the title)
        // and the final upwward stroke of the check mark is drawn
        // The indicator glows a certain color and pulses that color outwards

        crossDisolve(on: completedButton) {
            if completed {
                self.completedButton.isSelected = true
            } else {
                self.completedButton.isSelected = false
            }
        }

        crossDisolve(on: textView) {
            if completed {
                self.textView.textColor = UIColor.black.withAlphaComponent(0.2)
            } else {
                self.textView.textColor = .black
            }
        }

        animateChanges {
            if completed {
                self.completedButton.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            } else {
                self.completedButton.layer.borderColor = UIColor.black.cgColor
            }
        }

//        animateChanges {
//            if completed {
//                self.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.01)
//            } else {
//                self.contentView.backgroundColor = .white
//            }
//        }
    }

    // MARK: Highlighted

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            let scalar = AnimationValues.highlightScalar
            let duration = animated ? AnimationValues.highlightedTrueDuration : 0
            let translationX = AnimationValues.highlightedTranslationX
            UIView.animateInParallel(
                deleteButton.animateInParallel(
                    .scale(by: scalar, duration: duration),
                    .move(byX: translationX, y: 0, duration: duration)
                )
            )
        } else {
            // Always animate unhighlight
            let duration = AnimationValues.highlightedFalseDuration
            UIView.animateInParallel(
                deleteButton.animateInParallel(
                    .resetScale(duration: duration),
                    .resetPosition()
                )
            )
        }
    }

    // MARK: Selected

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Editing

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let transformValue: CGFloat = -15
        let duration: TimeInterval = animated ? 0.25 : 0
        if editing {
            UIView.animate(
                completedButton.animateInParallel(
                    .fadeOut(duration: duration),
                    .move(byX: transformValue, y: 0, duration: duration)
                ),
                deleteButton.animateInParallel(
                    .fadeIn(duration: duration),
                    .resetPosition(duration: duration)
                )
            )
        } else {
            // FIXME: setEditing is being called when the cell is selected/highlighted
            // (for instance, after a user taps a task to complete it)
            // and the complete button is moving when it shouldn't.
            UIView.animate(
                deleteButton.animateInParallel(
                    .fadeOut(duration: duration),
                    .move(byX: transformValue, y: 0, duration: duration)
                ),
                completedButton.animateInParallel(
                    .fadeIn(duration: duration),
                    .resetPosition(duration: duration)
                )
            )
        }
    }
}
