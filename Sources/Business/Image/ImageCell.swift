//
//  ImageCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(JSMediaBrowserImageCell)
open class ImageCell: BasisCell {
    
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
        if #available(iOS 11.0, *) {
            zoomImageView?.viewportSafeAreaInsets = self.safeAreaInsets
        }
        zoomImageView?.js_frameApplyTransform = self.contentView.bounds
    }
    
    @objc public override func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        super.updateCell(loaderEntity: loaderEntity, at: index)
        if let loaderEntity = loaderEntity as? ImageLoaderProtocol {
            loaderEntity.cancelRequest(forView: self.contentView)
            loaderEntity.request(forView: self.contentView) { [weak self](loader: LoaderProtocol, object: Any?, data: Data?) in
                let image: UIImage? = object as? UIImage
                self?.zoomImageView?.image = image
            } downloadProgress: { [weak self](loader: LoaderProtocol, progress: Progress?) in
                self?.didReceive(with: progress)
            } completed: { [weak self](loader: LoaderProtocol, object: Any?, data: Data?, error: NSError?, cancelled: Bool, finished: Bool) in
                self?.didCompleted(with: error, cancelled: cancelled, finished: finished)
                let image: UIImage? = object as? UIImage
                self?.zoomImageView?.image = image
            }
        }
    }
    
}
