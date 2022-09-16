//
//  VideoPlayerViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit

public protocol VideoPlayerViewDelegate: AnyObject {
    
    func videoPlayerViewDidReadyForDisplay(_ videoPlayerView: VideoPlayerView)
    
    func videoPlayerView(_ videoPlayerView: VideoPlayerView, progress currentTime: CGFloat, totalDuration: CGFloat)
    
    func videoPlayerViewDidPlayToEndTime(_ videoPlayerView: VideoPlayerView)
    
    func videoPlayerView(_ videoPlayerView: VideoPlayerView, didFailed error: NSError?)
    
}

extension VideoPlayerViewDelegate {
    
    public func videoPlayerViewDidReadyForDisplay(_ videoPlayerView: VideoPlayerView) {}
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, progress currentTime: CGFloat, totalDuration: CGFloat) {}
    public func videoPlayerViewDidPlayToEndTime(_ videoPlayerView: VideoPlayerView) {}
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, didFailed error: NSError?) {}
    
}
