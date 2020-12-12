//
//  BaseEntity.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserBaseEntity)
open class BaseEntity: NSObject, MediaBrowserViewSourceProtocol {
    
    public var sourceRect: CGRect = CGRect.zero
    public var sourceView: UIView?
    public var sourceCornerRadius: CGFloat = 0
    public var thumbImage: UIImage?
    
    public required init(sourceRect: CGRect, thumbImage: UIImage?) {
        super.init()
        self.sourceRect = sourceRect;
        self.thumbImage = thumbImage;
    }
    
    public required init(sourceView: UIView?, thumbImage: UIImage?) {
        super.init()
        self.sourceView = sourceView;
        self.thumbImage = thumbImage;
    }
    
}
