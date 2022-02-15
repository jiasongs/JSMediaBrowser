//
//  MediaBrowserViewControllerModifier.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/6/4.
//

import UIKit
import PhotosUI

public protocol MediaBrowserViewControllerModifier {
    
    func sourceViewForPageAtIndex(_ index: Int, in mediaBrowser: MediaBrowserViewController) -> UIView?
    
    func sourceViewCornerRadiusForPageAtIndex(_ index: Int, in mediaBrowser: MediaBrowserViewController) -> CGFloat
    
}

/// options
extension MediaBrowserViewControllerModifier {
    
    public func sourceViewForPageAtIndex(_ index: Int, in mediaBrowser: MediaBrowserViewController) -> UIView? {
        return nil
    }
    
    public func sourceViewCornerRadiusForPageAtIndex(_ index: Int, in mediaBrowser: MediaBrowserViewController) -> CGFloat {
        return 0
    }
    
}
