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
    
    func livePhotoView(in zoomImageView: ZoomImageView) -> any LivePhotoView
    
    func viewportRect(in zoomImageView: ZoomImageView) -> CGRect
    
}
