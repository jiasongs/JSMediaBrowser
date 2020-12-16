//
//  AppDelegate.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import MLeaksFinder

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NSObject.addClassNames(toWhitelist: ["JSMediaBrowserExample.MediaBrowserViewController"])
        return true
    }

}

