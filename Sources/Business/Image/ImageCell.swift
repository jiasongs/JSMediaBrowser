//
//  ImageCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public class ImageCell: BasisCell {
    
    public lazy var zoomImageView: ZoomImageView = {
        return ZoomImageView()
    }()
    
    public override func didInitialize() {
        super.didInitialize()
        self.contentView.addSubview(self.zoomImageView)
        self.contentView.sendSubviewToBack(self.zoomImageView)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.zoomImageView.stopAnimating()
        self.zoomImageView.image = nil
        self.zoomImageView.livePhoto = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomImageView.js_frameApplyTransform = self.contentView.bounds
    }
    
}
