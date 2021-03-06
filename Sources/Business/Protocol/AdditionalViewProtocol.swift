//
//  AdditionalViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/24.
//

import UIKit

public protocol AdditionalViewProtocol {
    
    func prepare(in viewController: MediaBrowserViewController)
    
    func layout(in viewController: MediaBrowserViewController)
    
    func totalUnitPageDidChange(_ totalUnitPage: Int, in viewController: MediaBrowserViewController)
    
    func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController)
    
    func didScroll(to index: Int, in viewController: MediaBrowserViewController)
    
}

extension AdditionalViewProtocol {
    
    func prepare(in viewController: MediaBrowserViewController) {}
    func layout(in viewController: MediaBrowserViewController) {}
    func totalUnitPageDidChange(_ totalUnitPage: Int, in viewController: MediaBrowserViewController) {}
    func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController) {}
    func didScroll(to index: Int, in viewController: MediaBrowserViewController) {}
    
}
