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
    @objc weak public var sourceView: UIView?
    @objc public var sourceCornerRadius: CGFloat = 0
    @objc public var thumbImage: UIImage?
    
    public required init(sourceView: UIView?, sourceRect: CGRect, thumbImage: UIImage?) {
        self.sourceView = sourceView
        self.thumbImage = thumbImage
    }
    
}
