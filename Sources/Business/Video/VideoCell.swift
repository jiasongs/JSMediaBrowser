//
//  VideoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import JSCoreKit

public class VideoCell: BasisCell {
    
    public lazy var videoPlayerView: VideoPlayerView = {
        return VideoPlayerView()
    }()
    
    public override func didInitialize() {
        super.didInitialize()
        self.contentView.addSubview(self.videoPlayerView)
        self.contentView.sendSubviewToBack(self.videoPlayerView)
        
        self.videoPlayerView.delegate = self
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.videoPlayerView.thumbImage = nil
        self.videoPlayerView.reset()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.videoPlayerView.js_frameApplyTransform = self.contentView.bounds
    }
    
}

extension VideoCell: VideoPlayerViewDelegate {    
    
    public func didReadyForDisplay(in videoPlayerView: VideoPlayerView) {
        self.setError(nil, cancelled: false)
    }
    
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, didFailed error: NSError?) {
        self.setError(error, cancelled: false)
    }
    
}
