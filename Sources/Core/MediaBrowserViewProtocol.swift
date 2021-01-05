//
//  MediaBrowserProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

@objc public protocol MediaBrowserViewDataSource: NSObjectProtocol {
    
    @objc(numberOfMediaItemsInBrowserView:)
    func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int
    
    @objc(mediaBrowserView:cellForItemAtIndex:)
    func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt index: Int) -> UICollectionViewCell
    
}

@objc public protocol MediaBrowserViewDelegate: NSObjectProtocol {
    
    @objc(mediaBrowserView:willDisplayCell:forItemAtIndex:)
    optional func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forItemAt index: Int)
    
    @objc(mediaBrowserView:didEndDisplaying:forItemAtIndex:)
    optional func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)
    
    @objc(mediaBrowserView:willScrollHalfFromIndex:toIndex:)
    optional func mediaBrowserView(_ browserView: MediaBrowserView, willScrollHalf fromIndex: Int, toIndex: Int)
    
    @objc(mediaBrowserView:didScrollToIndex:)
    optional func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int)
    
}

@objc public protocol MediaBrowserViewGestureDelegate: NSObjectProtocol {
    
    @objc(mediaBrowserView:singleTouchWithGestureRecognizer:)
    optional func mediaBrowserView(_ browserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer)
    
    @objc(mediaBrowserView:doubleTouchWithGestureRecognizer:)
    optional func mediaBrowserView(_ browserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer)
    
    @objc(mediaBrowserView:longPressWithGestureRecognizer:)
    optional func mediaBrowserView(_ browserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer)
    
    @objc(mediaBrowserView:dismissingWithGestureRecognizer:verticalDistance:)
    optional func mediaBrowserView(_ browserView: MediaBrowserView, dismissing gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat)
    
    @objc(mediaBrowserView:gestureRecognizer:shouldReceiveTouch:)
    optional func mediaBrowserView(_ browserView: MediaBrowserView, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    
}