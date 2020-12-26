//
//  ToolViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/24.
//

import UIKit

@objc public protocol ToolViewProtocol: NSObjectProtocol  {
    
    @objc optional func sourceItemsDidChange(in viewController: MediaBrowserViewController)
    
    @objc func didAddToSuperview(in viewController: MediaBrowserViewController)
    @objc optional func didLayoutSubviews(in viewController: MediaBrowserViewController)
    
    @objc optional func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController)
    @objc optional func didScrollTo(index: Int, in viewController: MediaBrowserViewController)
    @objc optional func didLongPress(gestureRecognizer: UILongPressGestureRecognizer, in viewController: MediaBrowserViewController)
    
}
