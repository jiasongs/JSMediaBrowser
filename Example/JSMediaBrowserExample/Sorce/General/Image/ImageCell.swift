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
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        zoomImageView?.image = nil
        zoomImageView?.livePhoto = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        zoomImageView?.js_frameApplyTransform = self.contentView.bounds
    }
    
    public override func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        super.updateCell(loaderEntity: loaderEntity, at: index)
        guard let loaderEntity = loaderEntity as? ImageLoaderEntity else { return }
        if let sourceItem: ImageEntity = loaderEntity.sourceItem as? ImageEntity {
            if let imageURL = sourceItem.imageUrl {
                self.zoomImageView?.sd_internalSetImage(with: imageURL, placeholderImage: sourceItem.thumbImage, options: SDWebImageOptions(rawValue: 0), context: nil, setImageBlock: { (image, imageData, cacheType, imageURL) in
                    self.zoomImageView?.image = image
                }, progress: nil, completed: { (image, data, errot, cache, bool, url) in
                    sourceItem.image = image
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
