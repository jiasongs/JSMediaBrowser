//
//  1.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2022/1/27.
//

import SDWebImage
import PhotosUI

public struct SDZoomImageViewModifier: ZoomImageViewModifier {
    
    var modifier = AnyZoomImageViewModifier()
    
    public func imageView(in zoomImageView: ZoomImageView) -> UIImageView {
        return SDAnimatedImageView()
    }
    
    public func livePhotoView(in zoomImageView: ZoomImageView) -> PHLivePhotoView {
        return self.modifier.livePhotoView(in: zoomImageView)
    }
    
    public func viewportRect(in zoomImageView: ZoomImageView) -> CGRect {
        return self.modifier.viewportRect(in: zoomImageView)
    }
    
}
