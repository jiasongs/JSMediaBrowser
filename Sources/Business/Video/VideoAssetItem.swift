//
//  VideoAssetItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import Foundation

public protocol VideoAssetItem: AssetItem {
    
    var videoURL: URL { get set }
    
}
