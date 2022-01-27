//
//  MediaBrowserViewPlugin.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public protocol MediaBrowserViewPlugin {
    
    func willDisplayCell(_ cell: UICollectionViewCell, forPageAt index: Int, in mediaBrowserView: MediaBrowserView)
    
    func didEndDisplayingCell(_ cell: UICollectionViewCell, forPageAt index: Int, in mediaBrowserView: MediaBrowserView)
    
    func willScrollHalfFrom(_ index: Int, toIndex: Int, in mediaBrowserView: MediaBrowserView)
    
    func didScrollTo(_ index: Int, in mediaBrowserView: MediaBrowserView)
    
    func singleTouch(_ gestureRecognizer: UITapGestureRecognizer, in mediaBrowserView: MediaBrowserView)
    
    func doubleTouch(_ gestureRecognizer: UITapGestureRecognizer, in mediaBrowserView: MediaBrowserView)
    
    func longPress(_ gestureRecognizer: UILongPressGestureRecognizer, in mediaBrowserView: MediaBrowserView)
    
    func dismissingShouldBegin(_ gestureRecognizer: UIPanGestureRecognizer, in mediaBrowserView: MediaBrowserView) -> Bool
    
    func dismissingChanged(_ gestureRecognizer: UIPanGestureRecognizer, in mediaBrowserView: MediaBrowserView)
    
}
