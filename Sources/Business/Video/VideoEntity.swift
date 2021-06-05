//
//  VideoEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import AVKit

public struct VideoEntity: VideoSourceProtocol {
    
    public var sourceRect: CGRect = CGRect.zero
    public var thumbImage: UIImage?
    
    public var videoUrl: URL?
    public var videoAsset: AVAsset?
    
    public init(sourceRect: CGRect = CGRect.zero, thumbImage: UIImage? = nil, videoUrl: URL? = nil, videoAsset: AVAsset? = nil) {
        self.sourceRect = sourceRect
        self.thumbImage = thumbImage
        self.videoUrl = videoUrl
        self.videoAsset = videoAsset
    }
    
}
