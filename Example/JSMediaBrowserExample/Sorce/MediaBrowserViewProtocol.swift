//
//  MediaBrowserViewProtocol.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

@objc public protocol MediaBrowserViewDataSource: NSObjectProtocol {
    
    func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int;
    func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell;
    
}

@objc public protocol MediaBrowserViewDelegate: NSObjectProtocol {
    
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath);
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath);
    
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, willScrollHalfTo index: Int);
    @objc optional func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int);
    
}
