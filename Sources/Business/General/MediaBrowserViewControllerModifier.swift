//
//  MediaBrowserViewControllerModifier.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/6/4.
//

import UIKit
import PhotosUI

public protocol MediaBrowserViewControllerModifier: AnyObject {
    
    func sourceViewForPageAtIndex(_ index: Int, in mediaBrowser: MediaBrowserViewController) -> UIView?
    
    func sourceViewCornerRadiusForPageAtIndex(_ index: Int, in mediaBrowser: MediaBrowserViewController) -> CGFloat
    
}
