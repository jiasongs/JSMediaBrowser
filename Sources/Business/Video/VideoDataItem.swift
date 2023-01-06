//
//  VideoDataItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import AVKit

public struct VideoDataItem: VideoDataItemProtocol {
    
    public var thumbImage: UIImage?
    
    public var videoUrl: URL?
    public var videoAsset: AVAsset?
    
    public init(videoUrl: URL? = nil, videoAsset: AVAsset? = nil, thumbImage: UIImage? = nil) {
        self.videoUrl = videoUrl
        self.videoAsset = videoAsset
        self.thumbImage = thumbImage
    }
    
}
