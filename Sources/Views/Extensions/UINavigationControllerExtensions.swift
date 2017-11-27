//
//  UINavigationControllerExtensions.swift
//  DWM
//
//  Created by Clay Ellis on 11/25/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

extension UINavigationController {
    var shadowImageView: UIView? {
        return navigationBar.allSubviews
            .flatMap { $0 as? UIImageView }
            .filter { $0.bounds.height < 1.0 }
            .first
    }
}
