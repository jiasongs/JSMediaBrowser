//
//  VideoPlayerViewPlugin.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit

public protocol VideoPlayerViewPlugin {
    
    func didReadyForDisplay(_ videoPlayerView: VideoPlayerView)
    
    func periodicTime(_ currentTime: CGFloat, totalDuration: CGFloat)
    
    func didPlayToEndTime(_ videoPlayerView: VideoPlayerView)
    
    func didFailed(_ videoPlayerView: VideoPlayerView, error: NSError?)
    
}
