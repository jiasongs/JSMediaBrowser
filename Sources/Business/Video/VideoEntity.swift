//
//  VideoEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import AVKit

@objc(JSMediaBrowserVideoEntity)
open class VideoEntity: BasisEntity, VideoSourceProtocol {
    
    @objc open var videoUrl: URL?
    @objc open var videoAsset: AVAsset?

}
