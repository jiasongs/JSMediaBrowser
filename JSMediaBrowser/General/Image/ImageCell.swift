//
//  ImageCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserImageCell)
open class ImageCell: BaseCell {
    
    @objc open var zoomImageView: ZoomImageView?
    
    open override func didInitialize() -> Void {
        super.didInitialize()
        zoomImageView = ZoomImageView()
        contentView.addSubview(zoomImageView!)
        contentView.sendSubviewToBack(zoomImageView!)
    }
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        zoomImageView?.image = nil
        zoomImageView?.livePhoto = nil
        /// gif图停止动画
        zoomImageView?.imageView.stopAnimating()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        zoomImageView?.js_frameApplyTransform = self.contentView.bounds
    }
    
    @objc public override func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        super.updateCell(loaderEntity: loaderEntity, at: index)
        if let sourceItem = loaderEntity.sourceItem as? ImageEntity {
            if sourceItem.image != nil {
                self.zoomImageView?.image = sourceItem.image
            } else if sourceItem.thumbImage != nil {
                self.zoomImageView?.image = sourceItem.thumbImage
            }
        }
    }
    
    @objc public override func loaderEntity(_ loaderEntity: LoaderProtocol, setData object: Any?, data: Data?) {
        super.loaderEntity(loaderEntity, setData: object, data: data)
        if let image = object as? UIImage {
            self.zoomImageView?.image = image
        }
    }
    
    @objc public override func loaderEntity(_ loaderEntity: LoaderProtocol, didCompleted object: Any?, data: Data?, error: NSError?, cancelled: Bool, finished: Bool) {
        super.loaderEntity(loaderEntity, didCompleted: object, data: data, error: error, cancelled: cancelled, finished: finished)
        if let image = object as? UIImage, error == nil {
            self.zoomImageView?.image = image
        }
    }
    
}
