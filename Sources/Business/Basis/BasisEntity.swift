//
//  BasisEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

open class BasisEntity: NSObject, SourceProtocol {
    
    public var sourceRect: CGRect = CGRect.zero
    public var thumbImage: UIImage?
    
    required public init(sourceRect: CGRect, thumbImage: UIImage?) {
        self.sourceRect = sourceRect
        self.thumbImage = thumbImage
    }
    
}
