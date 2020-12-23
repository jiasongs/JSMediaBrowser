//
//  MediaBrowserAppearance.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

@objc open class MediaBrowserAppearance: NSObject {
    
    @objc public static let appearance = MediaBrowserAppearance()
    
    @objc open var webImageMediatorClass: AnyClass<WebImageMediatorProtocol>?
    
}
