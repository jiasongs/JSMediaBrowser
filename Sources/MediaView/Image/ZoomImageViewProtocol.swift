//
//  ZoomImageViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/27.
//

import UIKit
import PhotosUI

public protocol ZoomImageViewDelegate: AnyObject {
    
    func zoomImageViewLazyBuildImageView(_ zoomImageView: ZoomImageView) -> UIImageView
    
    func zoomImageViewLazyBuildLivePhotoView(_ zoomImageView: ZoomImageView) -> PHLivePhotoView
    
    func zoomImageView(_ zoomImageView: ZoomImageView, finalViewportRect viewportRect: CGRect) -> CGRect
    
}

extension ZoomImageViewDelegate {
    
    public func zoomImageViewLazyBuildImageView(_ zoomImageView: ZoomImageView) -> UIImageView {
        return UIImageView()
    }
    
    public func zoomImageViewLazyBuildLivePhotoView(_ zoomImageView: ZoomImageView) -> PHLivePhotoView {
        return PHLivePhotoView()
    }
    
    public func zoomImageView(_ zoomImageView: ZoomImageView, finalViewportRect viewportRect: CGRect) -> CGRect {
        return CGRect.zero
    }
    
}
