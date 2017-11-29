//
//  UIButtonExtensions.swift
//  DWM
//
//  Created by Clay Ellis on 11/25/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

extension UIButton {
    /// Set the button's background color for a control state
    public func setBackgroundColor(_ color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(UIImage(color: color), for: state)
    }

    /// Returns the background color used for a button state.
    /// - parameter state: The state that uses the background color. Possible values are described in UIControlState.
    /// - returns: The background color used for the specified state.
    public func backgroundColor(for state: UIControlState) -> UIColor? {
        let image = backgroundImage(for: state)
        return image?.color(at: .zero)
    }

    /// Adds `space` between the button's `imageView` and `titleLabel`
    /// with the `imageView` on the left.
    func setImageTitleSpacing(_ space: CGFloat) {
        let inset = space / 2
        imageEdgeInsets.left = -inset
        imageEdgeInsets.right = inset
        titleEdgeInsets.left = inset
        titleEdgeInsets.right = -inset
    }
}
