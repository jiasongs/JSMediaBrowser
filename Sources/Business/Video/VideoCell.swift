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
        self.pieProgressView.isHidden = true
        self.contentView.addSubview(self.videoPlayerView)
        self.contentView.sendSubviewToBack(self.videoPlayerView)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.pieProgressView.isHidden = true
        self.videoPlayerView.thumbImage = nil
        self.videoPlayerView.plugin = VideoCellPlayerPlugin(cell: self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.videoPlayerView.js_frameApplyTransform = self.contentView.bounds
    }
    
}

fileprivate struct VideoCellPlayerPlugin: VideoPlayerViewPlugin {
    
    weak var cell: VideoCell?
    
    func didReadyForDisplay(_ videoPlayerView: VideoPlayerView) {
        self.cell?.setError(nil, cancelled: false, finished: true)
    }
    
    func periodicTime(_ currentTime: CGFloat, totalDuration: CGFloat) {
        
    }
    
    func didPlayToEndTime(_ videoPlayerView: VideoPlayerView) {
        
    }
    
    func didFailed(_ videoPlayerView: VideoPlayerView, error: NSError?) {
        self.cell?.setError(error, cancelled: false, finished: true)
    }
    
}
