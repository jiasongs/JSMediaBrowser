//
//  MediaBrowserViewDelegate.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public protocol MediaBrowserViewDelegate: AnyObject {
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forPageAt index: Int)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forPageAt index: Int)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willScrollHalfFrom index: Int, toIndex: Int)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didScrollTo index: Int)
    
}

public protocol MediaBrowserViewGestureDelegate: AnyObject {
    
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer)
    
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
