//
//  MediaBrowserViewControllerProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/6/4.
//

import UIKit
import PhotosUI

@objc(JSMediaBrowserViewControllerSourceViewDelegate)
public protocol MediaBrowserViewControllerSourceViewDelegate: AnyObject {
    
    @objc optional func sourceViewForPageAtIndex(_ index: Int) -> UIView?
    
    @objc optional func sourceViewCornerRadiusForPageAtIndex(_ index: Int) -> CGFloat
    
}
