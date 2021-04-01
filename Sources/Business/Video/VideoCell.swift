//
//  VideoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import JSCoreKit

@objc(MediaBrowserVideoCell)
open class VideoCell: BasisCell {
    
    @objc open var videoPlayerView: VideoPlayerView?
    
    open override func didInitialize() -> Void {
        super.didInitialize()
        self.pieProgressView?.isHidden = true
        self.videoPlayerView = VideoPlayerView()
        self.contentView.addSubview(self.videoPlayerView!)
        self.contentView.sendSubviewToBack(self.videoPlayerView!)
    }
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        self.pieProgressView?.isHidden = true
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
            /// 前后url不相同时需要释放之前的player, 否则会先显示之前的画面, 再显示当前的
            if self.videoPlayerView?.url != sourceItem.videoUrl {
                self.videoPlayerView?.releasePlayer()
            }
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
