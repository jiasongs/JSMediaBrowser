//
//  BaseEntity.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserBaseEntity)
open class BaseEntity: NSObject, SourceProtocol {

    public var sourceRect: CGRect = CGRect.zero
    weak public var sourceView: UIView?
    public var sourceCornerRadius: CGFloat = 0
    public var thumbImage: UIImage?
        
    public required init(sourceView: UIView?, sourceRect: CGRect, thumbImage: UIImage?) {
        self.sourceView = sourceView
        self.thumbImage = thumbImage
    }
    
}
