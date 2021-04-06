//
//  ZoomImageViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/27.
//

import UIKit
import PhotosUI

@objc(JSMediaBrowserZoomImageViewDelegate)
public protocol ZoomImageViewDelegate: NSObjectProtocol {
    
    @objc optional func zoomImageViewLazyBuildImageView(_ zoomImageView: ZoomImageView) -> UIImageView
    
    @objc optional func zoomImageViewLazyBuildLivePhotoView(_ zoomImageView: ZoomImageView) -> PHLivePhotoView
    
    @objc optional func zoomImageView(_ zoomImageView: ZoomImageView, finalViewportRect viewportRect: CGRect) -> CGRect
    
}
