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
        zoomImageView?.js_frameApplyTransform = self.contentView.bounds
    }
    
}
