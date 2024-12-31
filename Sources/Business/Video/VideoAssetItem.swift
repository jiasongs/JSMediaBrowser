//
//  VideoAssetItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import AVKit

public protocol VideoAssetItem: AssetItem {
    
    var videoUrl: URL? { get set }
    var videoAsset: AVAsset? { get set }
    
}
