//
//  LivePhotoAssetItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/2.
//

import Foundation

public protocol LivePhotoAssetItem: AssetItem {
    
    var imageURL: URL { get set }
    var videoURL: URL { get set }
    
}
