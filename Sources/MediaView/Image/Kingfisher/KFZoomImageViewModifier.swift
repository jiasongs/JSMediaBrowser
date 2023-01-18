//
//  KFZoomImageViewModifier.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2023/01/18.
//

import UIKit
import Kingfisher
import PhotosUI

public struct KFZoomImageViewModifier: ZoomImageViewModifier {
    
    public func imageView(in zoomImageView: ZoomImageView) -> UIImageView {
        let imageView = AnimatedImageView()
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
