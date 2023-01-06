//
//  SDZoomImageViewModifier.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2022/1/27.
//

import UIKit
import SDWebImage
import PhotosUI

public struct SDZoomImageViewModifier: ZoomImageViewModifier {
    
    public func imageView(in zoomImageView: ZoomImageView) -> UIImageView {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = false
        return imageView
    }
    
    public func livePhotoView(in zoomImageView: ZoomImageView) -> PHLivePhotoView {
       return PHLivePhotoView()
    }
    
    public func viewportRect(in zoomImageView: ZoomImageView) -> CGRect {
        return CGRect.zero
    }
    
    public init() {
        
    }
    
}
