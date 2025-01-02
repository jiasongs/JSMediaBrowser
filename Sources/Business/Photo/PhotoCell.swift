//
//  PhotoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public class PhotoCell: BasisCell {
    
    public lazy var zoomView: ZoomView = {
        return ZoomView()
    }()
    
    public override func didInitialize() {
        super.didInitialize()
        self.contentView.insertSubview(self.zoomView, at: 0)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.zoomView.stopPlaying()
        self.zoomView.asset = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomView.js_frameApplyTransform = self.contentView.bounds
    }
    
}
