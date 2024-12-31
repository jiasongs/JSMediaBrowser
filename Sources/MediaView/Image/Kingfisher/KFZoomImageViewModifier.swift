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
        if #available(iOS 17.0, *) {
            imageView.preferredImageDynamicRange = .high
        }
        return imageView
    }
    
    public func livePhotoView(in zoomImageView: ZoomImageView) -> any LivePhotoView {
        return PHLivePhotoView()
    }
    
    public init() {
        
    }
    
}
