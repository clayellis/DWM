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
        let container = DependencyContainer()
//        let dataPopulator = container.makeDataPopulator()
//        dataPopulator.populateData()

        // TODO: Delegate window and view state to AppCoordinator
        window = UIWindow(frame: UIScreen.main.bounds)
        let carousel = container.makeTaskListCarouselController()
        let navigationController = BaseNavigationController(rootViewController: carousel)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}
