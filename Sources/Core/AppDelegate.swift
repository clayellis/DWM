//
//  AppDelegate.swift
//  DWM
//
//  Created by Clay Ellis on 11/10/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // TODO: Delegate window and view state to AppCoordinator
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ListsViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
