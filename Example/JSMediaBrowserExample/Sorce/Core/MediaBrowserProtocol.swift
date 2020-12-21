//
//  MediaBrowserProtocol.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

@objc public protocol MediaBrowserViewDataSource: NSObjectProtocol {
    
    @objc func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int
    @objc func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt index: Int) -> UICollectionViewCell
    
}

@objc public protocol MediaBrowserViewDelegate: NSObjectProtocol {
    
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forItemAt index: Int)
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, willScrollHalf fromIndex: Int, toIndex: Int)
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int)
    
}

@objc public protocol MediaBrowserViewGestureDelegate: NSObjectProtocol {
    
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer)
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer)
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer)
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissing gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat)
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    
}
