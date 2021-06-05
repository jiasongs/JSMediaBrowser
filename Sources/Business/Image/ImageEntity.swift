//
//  ImageEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public struct ImageEntity: ImageSourceProtocol {
    
    public var sourceRect: CGRect = CGRect.zero
    public var thumbImage: UIImage?

    public var image: UIImage?
    public var imageUrl: URL?
    
    public init(sourceRect: CGRect = CGRect.zero, thumbImage: UIImage? = nil, image: UIImage? = nil, imageUrl: URL? = nil) {
        self.sourceRect = sourceRect
        self.thumbImage = thumbImage
        self.image = image
        self.imageUrl = imageUrl
    }
    
}
