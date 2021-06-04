//
//  ToolViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/24.
//

import UIKit

public protocol ToolViewProtocol: AnyObject {
    
    func prepare(in viewController: MediaBrowserViewController)
    
    func layoutView(in viewController: MediaBrowserViewController)
    
    func itemsDidChange(in viewController: MediaBrowserViewController)
    
    func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController)
    
    func didScrollTo(index: Int, in viewController: MediaBrowserViewController)
    
}

extension ToolViewProtocol {
    
    func prepare(in viewController: MediaBrowserViewController) {}
    func layoutView(in viewController: MediaBrowserViewController) {}
    func itemsDidChange(in viewController: MediaBrowserViewController) {}
    func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController) {}
    func didScrollTo(index: Int, in viewController: MediaBrowserViewController) {}
    
}
