//
//  ToolViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/24.
//

import UIKit

@objc(MediaBrowserToolViewProtocol)
public protocol ToolViewProtocol: NSObjectProtocol  {
    
    @objc(sourceItemsDidChangeInViewController:)
    optional func sourceItemsDidChange(in viewController: MediaBrowserViewController)
    
    @objc(didAddToSuperviewInViewController:)
    func didAddToSuperview(in viewController: MediaBrowserViewController)
    
    @objc(didLayoutSubviewsInViewController:)
    optional func didLayoutSubviews(in viewController: MediaBrowserViewController)
    
    @objc(willScrollHalfFromIndex:toIndex:inViewController:)
    optional func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController)
    
    @objc(didScrollToIndex:inViewController:)
    optional func didScrollTo(index: Int, in viewController: MediaBrowserViewController)
    
    @objc(didLongPressWithGestureRecognizer:inViewController:)
    optional func didLongPress(gestureRecognizer: UILongPressGestureRecognizer, in viewController: MediaBrowserViewController)
    
}
