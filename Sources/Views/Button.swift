//
//  Button.swift
//  DWM
//
//  Created by Clay Ellis on 12/1/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

/// A `UIButton` subclass that has an adjustable hit target.
class Button: UIButton {

    /// The minimum hit target size.
    var minimumHitTargetSize: CGSize = CGSize(width: 44, height: 44)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isEnabled, isUserInteractionEnabled, !isHidden, alpha != 0, minimumHitTargetSize != .zero else {
            return super.point(inside: point, with: event)
        }
        let widthOffset = max(minimumHitTargetSize.width - bounds.width, 0)
        let heightOffset = max(minimumHitTargetSize.height - bounds.height, 0)
        let hitTarget = bounds.insetBy(dx: -widthOffset / 2, dy: -heightOffset / 2)
        return hitTarget.contains(point)
    }
}
