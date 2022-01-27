//
//  ZoomImageViewModifier.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/27.
//

import UIKit
import PhotosUI

public protocol ZoomImageViewModifier {
    
    func imageView(in zoomImageView: ZoomImageView) -> UIImageView
    
    func livePhotoView(in zoomImageView: ZoomImageView) -> PHLivePhotoView
    
    func viewportRect(in zoomImageView: ZoomImageView) -> CGRect
    
}

public struct AnyZoomImageViewModifier: ZoomImageViewModifier {
    
    public func imageView(in zoomImageView: ZoomImageView) -> UIImageView {
        return UIImageView()
    }
    
    public func livePhotoView(in zoomImageView: ZoomImageView) -> PHLivePhotoView {
        return PHLivePhotoView()
    }
    
    public func viewportRect(in zoomImageView: ZoomImageView) -> CGRect {
        return CGRect.zero
    }
    
}
