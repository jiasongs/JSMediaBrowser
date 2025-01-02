//
//  Browser.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2025/1/2.
//

import UIKit
import JSMediaBrowser

struct ImageItem: ImageAssetItem {
    
    var thumbImage: UIImage?
    
    var image: UIImage?
    var imageURL: URL?
    
    init(image: UIImage? = nil, imageURL: URL? = nil, thumbImage: UIImage? = nil) {
        self.image = image
        self.imageURL = imageURL
        self.thumbImage = thumbImage
    }
    
}

struct VideoItem: VideoAssetItem {
    
    var thumbImage: UIImage?
    
    var videoURL: URL
    
    init(videoURL: URL, thumbImage: UIImage? = nil) {
        self.videoURL = videoURL
        self.thumbImage = thumbImage
    }
    
}

struct LivePhotoItem: LivePhotoAssetItem {
    
    var thumbImage: UIImage?
    
    var imageURL: URL
    var videoURL: URL
    
    init(imageURL: URL, videoURL: URL, thumbImage: UIImage? = nil) {
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.thumbImage = thumbImage
    }
    
}
