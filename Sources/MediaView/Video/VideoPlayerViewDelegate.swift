//
//  VideoPlayerViewDelegate.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit

public protocol VideoPlayerViewDelegate: AnyObject {
    
    func didReadyForDisplay(in videoPlayerView: VideoPlayerView)
    
    func didPlayToEndTime(in videoPlayerView: VideoPlayerView)
    
    func videoPlayerView(_ videoPlayerView: VideoPlayerView, periodicTime currentTime: CGFloat, totalDuration: CGFloat)
    
    func videoPlayerView(_ videoPlayerView: VideoPlayerView, didFailed error: NSError?)
    
}

/// options
extension VideoPlayerViewDelegate {
    
    public func didReadyForDisplay(in videoPlayerView: VideoPlayerView) {}
    
    public func didPlayToEndTime(in videoPlayerView: VideoPlayerView) {}
    
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, periodicTime currentTime: CGFloat, totalDuration: CGFloat) {}
    
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, didFailed error: NSError?) {}
    
}
