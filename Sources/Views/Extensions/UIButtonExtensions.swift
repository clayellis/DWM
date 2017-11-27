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
}
