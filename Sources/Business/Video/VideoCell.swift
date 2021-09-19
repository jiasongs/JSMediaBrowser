//
//  VideoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import JSCoreKit

open class VideoCell: BasisCell {
    
    open lazy var videoPlayerView: VideoPlayerView = {
        return VideoPlayerView()
    }()
    
    open override func didInitialize() {
        super.didInitialize()
        self.pieProgressView.isHidden = true
        self.contentView.addSubview(self.videoPlayerView)
        self.contentView.sendSubviewToBack(self.videoPlayerView)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.pieProgressView.isHidden = true
        self.videoPlayerView.thumbImage = nil
        self.videoPlayerView.delegate = self
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.videoPlayerView.js_frameApplyTransform = self.contentView.bounds
    }
    
}

extension VideoCell: VideoPlayerViewDelegate {
    
    public func videoPlayerViewDidReadyForDisplay(_ videoPlayerView: VideoPlayerView) {
        self.setError(nil, cancelled: false, finished: true)
    }
    
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, progress currentTime: CGFloat, totalDuration: CGFloat) {
        
    }
    
    public func videoPlayerViewDidPlayToEndTime(_ videoPlayerView: VideoPlayerView) {
        
    }
    
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, didFailed error: NSError?) {
        self.setError(error, cancelled: false, finished: true)
    }
    
}
