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
    
    open override func updateCell(loaderEntity: MediaBrowserViewLoaderProtocol, at indexPath: IndexPath) -> Void {
        super.updateCell(loaderEntity: loaderEntity, at: indexPath)
        if let sourceItem: ImageEntity = loaderEntity.sourceItem as? ImageEntity {
            zoomImageView?.sd_internalSetImage(with: sourceItem.imageURL, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), context: nil, setImageBlock: nil, progress: nil) { (image, data, eror, type, finshed, url) in
                self.zoomImageView?.image = image;
            }
        }
        
    }
    
}
