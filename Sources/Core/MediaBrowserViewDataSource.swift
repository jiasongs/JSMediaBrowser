//
//  MediaBrowserViewDataSource.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2022/1/27.
//

import UIKit

public protocol MediaBrowserViewDataSource: AnyObject {
    
    func numberOfPages(in mediaBrowserView: MediaBrowserView) -> Int
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, cellForPageAt index: Int) -> UICollectionViewCell
    
}
