//
//  TextView.swift
//  DWM
//
//  Created by Clay Ellis on 11/30/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// FIXME: When editing a task that has a title, and then deleting the title so the placeholder shows, the table view jumps slightly. It shouldn't.

/// A `UITextView` subclass which adds a placeholder.
class TextView: UITextView {

    // MARK: Overrides

    override var text: String! {
        didSet {
            updatePlaceholder()
        }
    }

    override var font: UIFont? {
        didSet {
            if let font = font {
                defaultPlaceholderAttributes[.font] = font
            } else {
                defaultPlaceholderAttributes[.font] = defaultFont
            }
            updatePlaceholder()
        }
    }

    override var textContainerInset: UIEdgeInsets {
        didSet {
            var copy = textContainerInset
            copy.left += leftAdjustment
            placeholderInsets = copy
        }
    }

    // MARK: Public

    /// The string that is displayed when there is no other text in the text field.
    var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    /// The styled string that is displayed when there is no other text in the text field.
    var attributedPlaceholder: NSAttributedString? {
        didSet {
            placeholder = attributedPlaceholder?.string
        }
    }

    /// The insets for the placeholder
    var placeholderInsets: UIEdgeInsets! {
        didSet {
            placeholderContainer.layoutMargins = placeholderInsets
            updatePlaceholder()
        }
    }

    // MARK: Private

    private let placeholderContainer = UIView()
    private let placeholderLabel = UILabel()

    private var defaultPlaceholderAttributes: [NSAttributedStringKey: Any]!
    private let defaultColor = UIColor.lightGray
    private let defaultFont = UIFont.preferredFont(forTextStyle: .body)
    private let leftAdjustment: CGFloat = 5

    override init(frame: CGRect = .zero, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: .UITextViewTextDidChange, object: self)
        configureDefaults()
        configurePlaceholder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureDefaults() {
        placeholderInsets = textContainerInset
        placeholderInsets.left += leftAdjustment
        defaultPlaceholderAttributes = [
            NSAttributedStringKey.foregroundColor: defaultColor,
            NSAttributedStringKey.font: defaultFont
        ]
    }

    private func configurePlaceholder() {
        addAutoLayoutSubview(placeholderContainer)
        placeholderContainer.addAutoLayoutSubview(placeholderLabel)
        sendSubview(toBack: placeholderContainer)
        placeholderContainer.fillSuperview()
        placeholderLabel.fillSuperviewLayoutMargins()
    }

    // MARK: Text Did Change

    @objc private func textDidChange(_ notification: NSNotification) {
        updatePlaceholder()
    }

    // MARK: Updates

    private func updatePlaceholder() {
        if let text = text, !text.isEmpty {
            placeholderLabel.attributedText = nil
        } else if let placeholderString = placeholder {
            let attributedString = attributedPlaceholder ?? NSAttributedString(string: placeholderString, attributes: defaultPlaceholderAttributes)
            placeholderLabel.attributedText = attributedString
        } else {
            placeholderLabel.attributedText = nil
        }
    }
}
