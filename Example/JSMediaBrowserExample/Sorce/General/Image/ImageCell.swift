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
        if let sourceItem = loaderEntity.sourceItem as? ImageEntity {
            if sourceItem.image != nil {
                self.zoomImageView?.image = sourceItem.image
            } else if sourceItem.thumbImage != nil {
                self.zoomImageView?.image = sourceItem.thumbImage
            }
        }
        loaderEntity.request()
        loaderEntity.willLoadBlock = {
            self.pieProgressView?.isHidden = false
        }
        loaderEntity.downloadProgressBlock = { (receivedSize: Int, expectedSize: Int) -> Void in
            self.pieProgressView?.setProgress(Float(receivedSize / expectedSize), animated: true)
        }
        loaderEntity.completedBlock = { (data: Any?, error: Error?, finished: Bool) -> Void in
            self.pieProgressView?.isHidden = true
//            if let image = data as? UIImage {
//                sourceItem.image = image
//            }
        }
    }
    
}
