//
//  ImageCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public class ImageCell: BasisCell {
    
    public lazy var zoomView: ZoomView = {
        return ZoomView()
    }()
    
    public override func didInitialize() {
        super.didInitialize()
        self.contentView.insertSubview(self.zoomView, at: 0)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.zoomView.stopAnimating()
        self.zoomView.image = nil
        self.zoomView.livePhoto = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomView.js_frameApplyTransform = self.contentView.bounds
    }
    
}
