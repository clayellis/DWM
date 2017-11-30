//
//  BaseNavigationController.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

final class BaseNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.isTranslucent = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // TODO: When iPad support is eventually added, return .all for iPad
        return .portrait
    }
}
