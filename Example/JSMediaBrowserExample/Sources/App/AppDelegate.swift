//
//  AppDelegate.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
#if !targetEnvironment(macCatalyst)
import MLeaksFinder
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = QMUINavigationController(rootViewController: HomeViewController())
        self.window?.makeKeyAndVisible()
        return true
    }

}

