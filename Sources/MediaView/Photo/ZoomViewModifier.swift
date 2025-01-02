//
//  ZoomViewModifier.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/27.
//

import UIKit

public protocol ZoomViewModifier {
    
    func assetView(in zoomView: ZoomView, asset: any ZoomAsset) -> (any ZoomAssetView)?
    
}
