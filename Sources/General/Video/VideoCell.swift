//
//  VideoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import JSCoreKit

@objc(MediaBrowserVideoCell)
open class VideoCell: BaseCell {
    
    @objc open var videoPlayerView: VideoPlayerView?
    
    open override func didInitialize() -> Void {
        super.didInitialize()
        self.videoPlayerView = VideoPlayerView()
        self.contentView.addSubview(self.videoPlayerView!)
        contentView.sendSubviewToBack(self.videoPlayerView!)
    }
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        self.pieProgressView?.isHidden = true
        self.videoPlayerView?.reset()
        self.videoPlayerView?.thumbImage = nil
        self.videoPlayerView?.delegate = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.videoPlayerView?.js_frameApplyTransform = self.contentView.bounds
    }
    
    @objc public override func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        super.updateCell(loaderEntity: loaderEntity, at: index)
        if let sourceItem = loaderEntity.sourceItem as? VideoSourceProtocol {
            self.videoPlayerView?.delegate = self
            self.videoPlayerView?.thumbImage = sourceItem.thumbImage
            self.videoPlayerView?.url = sourceItem.videoUrl
        }
    }
    
}

extension VideoCell: VideoPlayerViewDelegate {
    
    public func videoPlayerViewDidReadyForDisplay(_ videoPlayerView: VideoPlayerView) {
        self.didCompleted(with: nil, cancelled: false, finished: true)
    }
    
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, progress currentTime: CGFloat, totalDuration: CGFloat) {
        
    }
    
    public func videoPlayerViewDidPlayToEndTime(_ videoPlayerView: VideoPlayerView) {
        
    }
    
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, didFailed error: NSError?) {
        self.didCompleted(with: error, cancelled: false, finished: true)
    }
    
}
