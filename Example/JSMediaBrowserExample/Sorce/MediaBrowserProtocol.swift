//
//  MediaBrowserProtocol.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

@objc public protocol MediaBrowserViewDataSource: NSObjectProtocol {
    
    @objc func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int;
    @objc func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell;
    
}

@objc public protocol MediaBrowserViewDelegate: NSObjectProtocol {
    
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath);
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath);
    
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, willScrollHalfTo index: Int);
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int);
    
}

@objc public protocol MediaBrowserViewGestureDelegate: NSObjectProtocol {
    
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer)
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer)
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer)
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissing gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat)
    @objc optional func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    
}

@objc public protocol MediaBrowserViewSourceProtocol: NSObjectProtocol {
    
    @objc var sourceRect: CGRect { get set }
    @objc weak var sourceView: UIView? { get set }
    @objc var thumbImage: UIImage? { get set }
    
    
}
