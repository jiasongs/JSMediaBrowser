//
//  1.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2022/1/27.
//

import SDWebImage
import PhotosUI

public class SDZoomImageViewModifier: ZoomImageViewModifier {
    
    public static let defaultModifier: SDZoomImageViewModifier = SDZoomImageViewModifier()
    
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
    
}
