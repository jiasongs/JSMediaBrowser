//
//  MediaBrowserProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public protocol MediaBrowserViewDataSource: AnyObject {
    
    func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int
    
    func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt index: Int) -> UICollectionViewCell
    
}

public protocol MediaBrowserViewDelegate: AnyObject {
    
    func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forItemAt index: Int)
    
    func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)
    
    func mediaBrowserView(_ browserView: MediaBrowserView, willScrollHalf fromIndex: Int, toIndex: Int)
    
    func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int)
    
}

public protocol MediaBrowserViewGestureDelegate: AnyObject {
    
    func mediaBrowserView(_ browserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer)
    
    func mediaBrowserView(_ browserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer)
    
    func mediaBrowserView(_ browserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer)
    
    func mediaBrowserView(_ browserView: MediaBrowserView, dismissingChanged gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat)
    
    func mediaBrowserView(_ browserView: MediaBrowserView, dismissingShouldBegin gestureRecognizer: UIPanGestureRecognizer) -> Bool
    
}

extension MediaBrowserViewDelegate {
    
    func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forItemAt index: Int) {
        
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int) {
        
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, willScrollHalf fromIndex: Int, toIndex: Int) {
        
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int) {
        
    }
    
}

extension MediaBrowserViewGestureDelegate {
    
    func mediaBrowserView(_ browserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer) {
        
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, dismissingChanged gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat) {
        
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, dismissingShouldBegin gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return true
    }
    
}
