//
//  MediaBrowserViewDelegate.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public protocol MediaBrowserViewDelegate: AnyObject {
    
    func willDisplayCell(_ cell: UICollectionViewCell, forPageAt index: Int, in mediaBrowserView: MediaBrowserView)
    
    func didEndDisplayingCell(_ cell: UICollectionViewCell, forPageAt index: Int, in mediaBrowserView: MediaBrowserView)
    
    func willScrollHalfFrom(_ index: Int, toIndex: Int, in mediaBrowserView: MediaBrowserView)
    
    func didScrollTo(_ index: Int, in mediaBrowserView: MediaBrowserView)
    
}

public protocol MediaBrowserViewGestureDelegate: AnyObject {
    
    func singleTouch(_ gestureRecognizer: UITapGestureRecognizer, in mediaBrowserView: MediaBrowserView)
    
    func doubleTouch(_ gestureRecognizer: UITapGestureRecognizer, in mediaBrowserView: MediaBrowserView)
    
    func longPress(_ gestureRecognizer: UILongPressGestureRecognizer, in mediaBrowserView: MediaBrowserView)
    
    func dismissingShouldBegin(_ gestureRecognizer: UIPanGestureRecognizer, in mediaBrowserView: MediaBrowserView) -> Bool
    
    func dismissingChanged(_ gestureRecognizer: UIPanGestureRecognizer, in mediaBrowserView: MediaBrowserView)
    
}

/// options
//extension MediaBrowserViewDelegate {
//    
//    public func willDisplayCell(_ cell: UICollectionViewCell, forPageAt index: Int, in mediaBrowserView: MediaBrowserView) {}
//    
//    public func didEndDisplayingCell(_ cell: UICollectionViewCell, forPageAt index: Int, in mediaBrowserView: MediaBrowserView) {}
//    
//    public func willScrollHalfFrom(_ index: Int, toIndex: Int, in mediaBrowserView: MediaBrowserView) {}
//    
//    public func didScrollTo(_ index: Int, in mediaBrowserView: MediaBrowserView) {}
//    
//}
//
//extension MediaBrowserViewGestureDelegate {
//    
//    public func singleTouch(_ gestureRecognizer: UITapGestureRecognizer, in mediaBrowserView: MediaBrowserView) {}
//    
//    public func doubleTouch(_ gestureRecognizer: UITapGestureRecognizer, in mediaBrowserView: MediaBrowserView) {}
//    
//    public func longPress(_ gestureRecognizer: UILongPressGestureRecognizer, in mediaBrowserView: MediaBrowserView) {}
//    
//    public func dismissingShouldBegin(_ gestureRecognizer: UIPanGestureRecognizer, in mediaBrowserView: MediaBrowserView) -> Bool {
//        return true
//    }
//    
//    public func dismissingChanged(_ gestureRecognizer: UIPanGestureRecognizer, in mediaBrowserView: MediaBrowserView) {}
//    
//}
