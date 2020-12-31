//
//  ImageEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserImageEntity)
open class ImageEntity: BaseEntity, ImageSourceProtocol {
    
    @objc open var image: UIImage?
    @objc open var imageUrl: URL?

}
