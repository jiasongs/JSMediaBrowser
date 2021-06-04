//
//  MediaBrowserViewControllerProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/6/4.
//

import UIKit

@objc(JSMediaBrowserViewControllerProtocol)
public protocol MediaBrowserViewControllerProtocol: AnyObject {
    
    
    
}

@objc(JSMediaBrowserViewControllerSourceViewProtocol)
public protocol MediaBrowserViewControllerSourceViewDelegate: AnyObject {
    
    @objc optional func sourceViewForPageAtIndex(_ index: Int) -> UIView?
    
    @objc optional func sourceViewCornerRadiusForPageAtIndex(_ index: Int) -> CGFloat
    
}
