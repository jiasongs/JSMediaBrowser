//
//  ImageDataItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public struct ImageDataItem: ImageDataItemProtocol {
    
    public var thumbImage: UIImage?
    public var webImageMediator: WebImageMediator?

    public var image: UIImage?
    public var imageUrl: URL?
    
    public init(image: UIImage? = nil, imageUrl: URL? = nil, thumbImage: UIImage? = nil) {
        self.image = image
        self.imageUrl = imageUrl
        self.thumbImage = thumbImage
    }
    
}
