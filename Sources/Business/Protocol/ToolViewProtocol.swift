//
//  ToolViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/24.
//

import UIKit

public protocol ToolViewProtocol {
    
    func toolView(_ toolView: ToolViewProtocol, prepare viewController: MediaBrowserViewController)
    
    func toolView(_ toolView: ToolViewProtocol, layout viewController: MediaBrowserViewController)
    
    func toolView(_ toolView: ToolViewProtocol, pageDidChange viewController: MediaBrowserViewController)
    
    func toolView(_ toolView: ToolViewProtocol, willScrollHalf fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController)
    
    func toolView(_ toolView: ToolViewProtocol, didScrollTo index: Int, in viewController: MediaBrowserViewController)
    
}

extension ToolViewProtocol {
    
    func toolView(_ toolView: ToolViewProtocol, prepare viewController: MediaBrowserViewController) {}
    func toolView(_ toolView: ToolViewProtocol, layout viewController: MediaBrowserViewController) {}
    func toolView(_ toolView: ToolViewProtocol, didChange viewController: MediaBrowserViewController) {}
    func toolView(_ toolView: ToolViewProtocol, willScrollHalf fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController) {}
    func toolView(_ toolView: ToolViewProtocol, didScrollTo index: Int, in viewController: MediaBrowserViewController) {}
    
}
