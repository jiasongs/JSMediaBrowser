//
//  ImageCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(JSMediaBrowserImageCell)
open class ImageCell: BasisCell {
    
    @objc lazy open var zoomImageView: ZoomImageView = {
        return ZoomImageView()
    }()
    
    open override func didInitialize() -> Void {
        super.didInitialize()
        self.contentView.addSubview(self.zoomImageView)
        self.contentView.sendSubviewToBack(self.zoomImageView)
    }
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        self.zoomImageView.stopAnimating()
        self.zoomImageView.image = nil
        self.zoomImageView.livePhoto = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomImageView.js_frameApplyTransform = self.contentView.bounds
    }
    
}
