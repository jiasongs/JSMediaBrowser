//
//  MediaBrowserViewDataSource.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2022/1/27.
//

import UIKit

public protocol MediaBrowserViewDataSource: AnyObject {
    
    func numberOfPages(in mediaBrowserView: MediaBrowserView) -> Int
    
    func cellForPage(at index: Int, in mediaBrowserView: MediaBrowserView) -> UICollectionViewCell
    
}
