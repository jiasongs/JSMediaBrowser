//
//  ImageCell.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit
import SDWebImage

@objc(MediaBrowserImageCell)
open class ImageCell: BaseCell {
    
    @objc open var zoomImageView: ZoomImageView?

    open override func didInitialize() -> Void {
        super.didInitialize()
        zoomImageView = ZoomImageView.init()
        contentView.addSubview(zoomImageView!)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        zoomImageView?.js_frameApplyTransform = self.contentView.bounds
    }
        
    open override func updateCell(loaderEntity: LoaderProtocol, at indexPath: IndexPath) -> Void {
        super.updateCell(loaderEntity: loaderEntity, at: indexPath)
        if let sourceItem: ImageEntity = loaderEntity.sourceItem as? ImageEntity {
            if let imageURL = sourceItem.imageUrl {
                loaderEntity.webImageMediator?.loadImage(url:imageURL, progress: { (receivedSize, expectedSize) in
                    
                }, completed: { (image, error, finished) in
                    self.zoomImageView?.image = image;
                })
            }
        }
        
    }
    
}
