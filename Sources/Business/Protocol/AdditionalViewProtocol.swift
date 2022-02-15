//
//  AdditionalViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/24.
//

import UIKit

public protocol AdditionalViewProtocol {
    
    func prepare(in mediaBrowser: MediaBrowserViewController)
    
    func layout(in mediaBrowser: MediaBrowserViewController)
    
    func totalUnitPageDidChange(_ totalUnitPage: Int, in mediaBrowser: MediaBrowserViewController)
    
    func willScrollHalf(fromIndex: Int, toIndex: Int, in mediaBrowser: MediaBrowserViewController)
    
    func didScroll(to index: Int, in mediaBrowser: MediaBrowserViewController)
    
}

/// options
extension AdditionalViewProtocol {
    
    public func prepare(in mediaBrowser: MediaBrowserViewController) {}
    
    public func layout(in mediaBrowser: MediaBrowserViewController) {}
    
    public func totalUnitPageDidChange(_ totalUnitPage: Int, in mediaBrowser: MediaBrowserViewController) {}
    
    public func willScrollHalf(fromIndex: Int, toIndex: Int, in mediaBrowser: MediaBrowserViewController) {}
    
    public func didScroll(to index: Int, in mediaBrowser: MediaBrowserViewController) {}
    
}
