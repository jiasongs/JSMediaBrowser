//
//  MediaBrowserViewControllerDelegate.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2023/1/5.
//

import UIKit

public protocol MediaBrowserViewControllerDelegate: AnyObject {
    
    func mediaBrowserViewController(_ mediaBrowserViewController: MediaBrowserViewController, willDisplay emptyView: EmptyView, error: NSError)
    
    func mediaBrowserViewController(_ mediaBrowserViewController: MediaBrowserViewController, layoutPageCells visibleCells: [UICollectionViewCell])
    
}

/// options
extension MediaBrowserViewControllerDelegate {
    
    public func mediaBrowserViewController(_ mediaBrowserViewController: MediaBrowserViewController, willDisplay emptyView: EmptyView, error: NSError) {}
    
    public func mediaBrowserViewController(_ mediaBrowserViewController: MediaBrowserViewController, layoutPageCells visibleCells: [UICollectionViewCell]) {}
    
}
