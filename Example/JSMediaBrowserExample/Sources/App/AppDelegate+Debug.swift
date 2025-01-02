//
//  AppDelegate+Debug.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2025/1/2.
//

import UIKit
#if canImport(MLeaksFinder)
import MLeaksFinder
#endif

extension AppDelegate {
    
    func configDebug() {
#if DEBUG
        NSObject.addClassNames(toWhitelist: [BrowserViewController.description()])
#endif
    }
    
}
