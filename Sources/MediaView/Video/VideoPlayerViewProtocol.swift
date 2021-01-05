//
//  VideoPlayerViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit

@objc(MediaBrowserVideoPlayerViewDelegate)
public protocol VideoPlayerViewDelegate: NSObjectProtocol {
    
    @objc optional func videoPlayerViewDidReadyForDisplay(_ videoPlayerView: VideoPlayerView)
    
    @objc optional func videoPlayerView(_ videoPlayerView: VideoPlayerView, progress currentTime: CGFloat, totalDuration: CGFloat)
    
    @objc optional func videoPlayerViewDidPlayToEndTime(_ videoPlayerView: VideoPlayerView)
    
    @objc optional func videoPlayerView(_ videoPlayerView: VideoPlayerView, didFailed error: NSError?)
    
}
