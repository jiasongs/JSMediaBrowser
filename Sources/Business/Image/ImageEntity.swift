//
//  ImageEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public struct ImageEntity: ImageSourceProtocol {
    
    public var thumbImage: UIImage?

    public var image: UIImage?
    public var imageUrl: URL?
    
    public init(image: UIImage? = nil, imageUrl: URL? = nil, thumbImage: UIImage? = nil) {
        self.image = image
        self.imageUrl = imageUrl
        self.thumbImage = thumbImage
    }
    
}
