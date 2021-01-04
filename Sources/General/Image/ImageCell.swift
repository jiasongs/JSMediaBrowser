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
        zoomImageView?.stopAnimating()
        zoomImageView?.image = nil
        zoomImageView?.livePhoto = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        zoomImageView?.js_frameApplyTransform = self.contentView.bounds
    }
    
    @objc public override func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        super.updateCell(loaderEntity: loaderEntity, at: index)
        if let loaderEntity = loaderEntity as? ImageLoaderProtocol {
            loaderEntity.cancelRequest(forView: self.contentView)
            loaderEntity.request(forView: self.contentView) { [weak self](loader: LoaderProtocol, object: Any?, data: Data?) in
                if let image = object as? UIImage {
                    self?.zoomImageView?.image = image
                }
            } downloadProgress: { [weak self](loader: LoaderProtocol, progress: Progress?) in
                self?.didReceive(with: progress)
            } completed: { [weak self](loader: LoaderProtocol, object: Any?, data: Data?, error: NSError?, cancelled: Bool, finished: Bool) in
                self?.didCompleted(with: error, cancelled: cancelled, finished: finished)
                if let image = object as? UIImage {
                    self?.zoomImageView?.image = image
                }
            }
        }
        if let sourceItem = loaderEntity.sourceItem as? ImageSourceProtocol {
            if sourceItem.image != nil {
                self.zoomImageView?.image = sourceItem.image
            } else if sourceItem.thumbImage != nil {
                self.zoomImageView?.image = sourceItem.thumbImage
            }
        }
    }
    
}
