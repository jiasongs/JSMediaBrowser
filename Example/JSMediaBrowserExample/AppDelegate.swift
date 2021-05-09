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
        #if !targetEnvironment(macCatalyst)
        NSObject.addClassNames(toWhitelist: ["_UIPageControlContentView"])
        #endif
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ExampleViewController())
        window?.makeKeyAndVisible()
        return true
    }

}

