//
//  ImageCell.swift
//  JSMediaBrowserExample
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
            self.pieProgressView?.isHidden = false
            loaderEntity.webImageMediator?.setImage(for: zoomImageView, url: sourceItem.imageUrl, thumbImage: sourceItem.thumbImage, setImageBlock: { (image: UIImage?, imageData: Data?) in
                self.zoomImageView?.image = image
            }, progress: { (receivedSize: Int64, expectedSize: Int64) in
                DispatchQueue.main.async {
                    if receivedSize > 0 && expectedSize > 0 {
                        let progress: Float = Float(receivedSize) / Float(expectedSize)
                        self.pieProgressView?.setProgress(progress, animated: true)
                    }
                }
            }, completed: { (image: UIImage?, imageData: Data?, error: Error?, finished: Bool) in
                DispatchQueue.main.async {
                    self.pieProgressView?.isHidden = true
                    if error == nil && image != nil {
                        self.zoomImageView?.image = image
                    }
                }
            })
        } else {
            print("12121213")
        }
    }
    
}
