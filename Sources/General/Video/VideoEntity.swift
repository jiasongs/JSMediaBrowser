//
//  VideoEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import AVKit

open class VideoEntity: BaseEntity, VideoSourceProtocol {
    
    @objc open var videoUrl: URL?
    @objc open var videoAsset: AVAsset?

}
