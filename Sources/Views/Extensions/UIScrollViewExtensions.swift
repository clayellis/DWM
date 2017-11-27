//
//  UIScrollViewExtensions.swift
//  DWM
//
//  Created by Clay Ellis on 11/25/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

extension UIScrollView {
    func forceDelaysContentTouches(_ force: Bool) {
        delaysContentTouches = force
        for scrollView in subviewsWithClassType(UIScrollView.self) {
            scrollView.delaysContentTouches = force
        }
    }
}
