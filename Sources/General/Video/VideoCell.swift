//
//  VideoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit

open class VideoCell: BaseCell {
    
    @objc open var videoPlayerView: VideoPlayerView?
    
    open override func didInitialize() -> Void {
        super.didInitialize()
        videoPlayerView = VideoPlayerView()
        contentView.addSubview(videoPlayerView!)
        contentView.sendSubviewToBack(videoPlayerView!)
    }
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        videoPlayerView?.reset()
        videoPlayerView?.thumbImage = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayerView?.js_frameApplyTransform = self.contentView.bounds
    }
    
    @objc public override func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        super.updateCell(loaderEntity: loaderEntity, at: index)
        if let sourceItem = loaderEntity.sourceItem as? VideoSourceProtocol {
            self.videoPlayerView?.thumbImage = sourceItem.thumbImage
            if sourceItem.videoUrl != nil {
                self.videoPlayerView?.url = sourceItem.videoUrl
            }
        }
    }
    
}
