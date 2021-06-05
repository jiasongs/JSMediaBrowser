//
//  VideoEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import AVKit

open class VideoEntity: BasisEntity, VideoSourceProtocol {
    
    open var videoUrl: URL?
    open var videoAsset: AVAsset?
    
}
