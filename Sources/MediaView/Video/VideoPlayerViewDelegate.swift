//
//  VideoPlayerViewDelegate.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit

public protocol VideoPlayerViewDelegate: AnyObject {
    
    func didReadyForDisplay(_ videoPlayerView: VideoPlayerView)
    
    func periodicTime(_ currentTime: CGFloat, totalDuration: CGFloat, in videoPlayerView: VideoPlayerView)
    
    func didPlayToEndTime(_ videoPlayerView: VideoPlayerView)
    
    func didFailed(_ videoPlayerView: VideoPlayerView, error: NSError?)
    
}

/// options
extension VideoPlayerViewDelegate {
    
    public func didReadyForDisplay(_ videoPlayerView: VideoPlayerView) {}
    
    public func periodicTime(_ currentTime: CGFloat, totalDuration: CGFloat, in videoPlayerView: VideoPlayerView) {}
    
    public func didPlayToEndTime(_ videoPlayerView: VideoPlayerView) {}
    
    public func didFailed(_ videoPlayerView: VideoPlayerView, error: NSError?) {}
    
}
