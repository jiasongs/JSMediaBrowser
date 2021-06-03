//
//  BasisEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(JSMediaBrowserBasisEntity)
open class BasisEntity: NSObject, SourceProtocol {
    
    @objc public var sourceRect: CGRect = CGRect.zero
    @objc public var thumbImage: UIImage?
    
    required public init(sourceRect: CGRect, thumbImage: UIImage?) {
        self.sourceRect = sourceRect
        self.thumbImage = thumbImage
    }
    
}
