//
//  1.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2022/1/27.
//

import SDWebImage
import PhotosUI

public struct SDZoomImageViewModifier: ZoomImageViewModifier {
    
    public func imageView(in zoomImageView: ZoomImageView) -> UIImageView {
        return SDAnimatedImageView()
    }
    
}
