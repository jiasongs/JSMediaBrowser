//
//  ZoomViewModifier.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/27.
//

import UIKit

public protocol ZoomViewModifier {
    
    func imageView(in zoomView: ZoomView) -> UIImageView
    
    func livePhotoView(in zoomView: ZoomView) -> any LivePhotoView
    
}
