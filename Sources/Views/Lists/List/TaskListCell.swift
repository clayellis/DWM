//
//  TaskListCell.swift
//  DWM
//
//  Created by Clay Ellis on 11/21/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// TODO: Add a placeholder to the textView
// TODO: Create a style manager for fonts, images, and colors

class TaskListCell: UITableViewCell {

    let textView = UITextView()
    let statusIndicator = UIButton()
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

        highlightArea.backgroundColor = .clear
        highlightArea.layer.cornerRadius = 10

        statusIndicator.layer.borderWidth = 2
        statusIndicator.layer.masksToBounds = true
        statusIndicator.layer.cornerRadius = Sizes.statusIndicatorRadius
        statusIndicator.setBackgroundColor(UIColor.clear, forUIControlState: .normal)
        statusIndicator.setBackgroundColor(UIColor.black.withAlphaComponent(0.1), forUIControlState: [.normal, .highlighted])
        statusIndicator.setBackgroundColor(UIColor.black.withAlphaComponent(0.2), forUIControlState: .selected)
        statusIndicator.setBackgroundColor(UIColor.black.withAlphaComponent(0.1), forUIControlState: [.selected, .highlighted])

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

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        crossDisolve(changes: self.statusIndicator.isHighlighted = highlighted, on: statusIndicator)

//        if highlighted {
//            self.highlightArea.transform = self.highlightArea.transform.scaledBy(x: <#T##CGFloat#>, y: <#T##CGFloat#>)
//        } else {
//
//        }
        animateChanges {
            // TODO: The highlight area should start slightly scaled and shrink back to normal
            if highlighted {
                self.highlightArea.backgroundColor = UIColor.black.withAlphaComponent(0.03)
            } else {
                self.highlightArea.backgroundColor = .clear
            }
        }
    }

    func animateChanges(_ animations: @escaping () -> ()) {
        // TODO: Consider using new animation API
        UIView.animate(withDuration: 0.15,
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
