//
//  MediaBrowserAppearance.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

public typealias BuildWebImageMediatorBlock = (MediaBrowserViewController, SourceProtocol) -> WebImageMediatorProtocol
public typealias BuildToolViewsBlock = (MediaBrowserViewController) -> Array<UIView & ToolViewProtocol>

@objc open class MediaBrowserAppearance: NSObject {
    
    @objc public static let appearance = MediaBrowserAppearance()
    
    @objc public var addWebImageMediatorBlock: BuildWebImageMediatorBlock?
    @objc open var addToolViewsBlock: BuildToolViewsBlock?
    @objc open var progressTintColor: UIColor?
    
}
