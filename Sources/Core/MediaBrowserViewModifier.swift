//
//  MediaBrowserViewModifier.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2022/1/27.
//

import UIKit

public protocol MediaBrowserViewModifier {
    
    func numberOfPages(in mediaBrowserView: MediaBrowserView) -> Int
    
    func cellForPage(at index: Int, in mediaBrowserView: MediaBrowserView) -> UICollectionViewCell
    
}
