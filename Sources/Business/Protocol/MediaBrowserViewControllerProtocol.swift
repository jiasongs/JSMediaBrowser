//
//  MediaBrowserViewControllerProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/6/4.
//

import UIKit
import PhotosUI

public protocol MediaBrowserViewControllerSourceViewDelegate: AnyObject {
    
    func sourceViewForPageAtIndex(_ index: Int) -> UIView?
    
    func sourceViewCornerRadiusForPageAtIndex(_ index: Int) -> CGFloat
    
}

extension MediaBrowserViewControllerSourceViewDelegate {
    
    func sourceViewForPageAtIndex(_ index: Int) -> UIView? {
        return nil
    }
    
    func sourceViewCornerRadiusForPageAtIndex(_ index: Int) -> CGFloat {
        return 0
    }
    
}
