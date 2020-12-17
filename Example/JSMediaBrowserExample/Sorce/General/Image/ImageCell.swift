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
        zoomImageView = ZoomImageView()
        contentView.addSubview(zoomImageView!)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        zoomImageView?.js_frameApplyTransform = self.contentView.bounds
    }
    
    public override func updateCell<T: LoaderProtocol>(loaderEntity: T, at indexPath: IndexPath) {
        super.updateCell(loaderEntity: loaderEntity, at: indexPath)
        guard let loaderEntity = loaderEntity as? ImageLoaderEntity else { return }
        if let sourceItem: ImageEntity = loaderEntity.sourceItem as? ImageEntity {
            if let imageURL = sourceItem.imageUrl {
                self.zoomImageView?.sd_internalSetImage(with: imageURL, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), context: nil, setImageBlock: nil, progress: nil, completed: { (image, data, errot, cache, bool, url) in
                    self.zoomImageView?.image = image;
                })
//                loaderEntity.webImageMediator?.loadImage(url:imageURL, progress: { (receivedSize, expectedSize) in
//
//                }, completed: { (image, error, finished) in
//                    self.zoomImageView?.image = image;
//                })
            }
        }
    }
    
}
