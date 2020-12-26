//
//  ToolViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/24.
//

import UIKit

@objc public protocol ToolViewProtocol: NSObjectProtocol  {
    
    @objc func sourceItemsDidChange(for browserViewController: MediaBrowserViewController)
    @objc func viewDidLoad(for browserViewController: MediaBrowserViewController)
    
    @objc optional func viewDidLayoutSubviews(for browserViewController: MediaBrowserViewController)
    @objc optional func viewWillAppear(for browserViewController: MediaBrowserViewController)
    @objc optional func viewWillDisappear(for browserViewController: MediaBrowserViewController)
    
    @objc optional func willScrollHalf(for browserViewController: MediaBrowserViewController, fromIndex: Int, toIndex: Int)
    @objc optional func didScrollTo(for browserViewController: MediaBrowserViewController, index: Int)
    @objc optional func didLongPress(for browserViewController: MediaBrowserViewController, gestureRecognizer: UILongPressGestureRecognizer)
    
}
