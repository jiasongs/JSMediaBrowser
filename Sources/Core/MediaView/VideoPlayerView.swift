//
//  VideoPlayerView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import MediaPlayer
import JSCoreKit

open class VideoPlayerView: BaseMediaView {
    
    var url: URL? {
        didSet {
            if let url = self.url {
                let item: AVPlayerItem = AVPlayerItem(url: url)
                self.playerItem = item
            }
        }
    }
    var asset: AVAsset? {
        didSet {
            if let asset = self.asset {
                let item: AVPlayerItem = AVPlayerItem(asset: asset)
                self.playerItem = item
            }
        }
    }
    @objc var playerItem: AVPlayerItem? {
        willSet {
            self.removeObserverForPlayer()
        }
        didSet {
            if self.playerItem != nil {
                self.addObserverForPlayer()
                self.player = AVPlayer(playerItem: playerItem)
            }
        }
    }
    private(set) var player: AVPlayer? {
        didSet {
            if let player = self.player {
                /// 初始化
                let _ = self.playerView
                self.playerLayer?.player = player;
                self.playerLayer?.videoGravity = .resizeAspect
                self.setNeedsLayout()
            }
        }
    }
    
    private var isPlayerViewInitialized = false
    @objc lazy var playerView: AVPlayerView  = {
        isPlayerViewInitialized = true
        let playerView = AVPlayerView()
        self.addSubview(playerView)
        return playerView
    }()
    private var playerLayer: AVPlayerLayer? {
        if isPlayerViewInitialized {
            return self.playerView.layer as? AVPlayerLayer
        }
        return nil
    }
    
    var currentTime: CGFloat {
        if let player = self.player {
            return CGFloat(CMTimeGetSeconds(player.currentTime()))
        }
        return 0
    }
    private(set) var totalDuration: CGFloat = 0.0
    
    var isAutoPlay: Bool = true
    
    private var isAddObserverForPlayer: Bool = false
    private var isAddObserverForSystem: Bool = false
    
    override func didInitialize(frame: CGRect) -> Void {
        super.didInitialize(frame: frame)
        self.addObserverForSystem()
    }
    
    deinit {
        self.removeObserverForPlayer()
        self.removeObserverForSystem()
    }
    
}

extension VideoPlayerView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.isPlayerViewInitialized {
            self.playerView.frame = self.finalViewportRect
        }
    }
    
}

extension VideoPlayerView {
    
    @objc open override var containerView: UIView? {
        return self
    }
    
    @objc open override var contentView: UIView? {
        if isPlayerViewInitialized {
            return self.playerView
        }
        return nil
    }
    
    @objc open override var contentViewRectInZoomView: CGRect {
        guard let contentView = self.contentView else { return CGRect.zero }
        guard let playerLayer = self.playerLayer else { return CGRect.zero }
        return self.convert(playerLayer.videoRect, from: contentView.superview)
    }
    
    open func play() -> Void {
        self.player?.play()
    }
    
    open func pause() -> Void {
        self.player?.pause()
    }
    
    open func reset() -> Void {
        
    }
    
    open func seek(to time: CGFloat, completionHandler: @escaping (Bool) -> Void) {
        guard let player = self.player else { return }
        let startTime: CMTime = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: player.currentTime().timescale);
        player.seek(to: CMTime(seconds: Double(startTime.value), preferredTimescale: CMTimeScale.zero), toleranceBefore: CMTimeMake(value: 1, timescale: 1000), toleranceAfter: CMTimeMake(value: 1, timescale: 1000), completionHandler: { (finished) in
            if (finished) {
                self.play()
            }
            completionHandler(finished)
        })
    }
    
}

extension VideoPlayerView {
    
    func addObserverForPlayer() -> Void {
        if !self.isAddObserverForPlayer {
            self.isAddObserverForPlayer = true
            self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
            self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: .new, context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        }
    }
    
    func removeObserverForPlayer() -> Void {
        if self.isAddObserverForPlayer {
            self.isAddObserverForPlayer = false
            self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        }
    }
    
    func addObserverForSystem() -> Void {
        if !self.isAddObserverForSystem {
            self.isAddObserverForSystem = true
            NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
    }
    
    func removeObserverForSystem() -> Void {
        if self.isAddObserverForSystem {
            self.isAddObserverForSystem = false
            NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change else { return }
        if keyPath == #keyPath(AVPlayerItem.status) {
            if let status: Int = change[NSKeyValueChangeKey.newKey] as? Int {
                if let currentItem = self.player?.currentItem, AVPlayer.Status(rawValue: status) == .readyToPlay {
                    self.totalDuration = CGFloat(CMTimeGetSeconds(currentItem.duration))
                    if self.isAutoPlay {
                        self.player?.play()
                    }
                }
            }
        } else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            if let loadedTimeRanges: Array<CMTimeRange> = change[NSKeyValueChangeKey.newKey] as? Array<CMTimeRange>, loadedTimeRanges.count > 0 {
                // 获取缓冲区域
                let timeRange: CMTimeRange = loadedTimeRanges.first ?? CMTimeRange.zero
                // 开始的时间
                let startSeconds: TimeInterval = CMTimeGetSeconds(timeRange.start)
                // 表示已经缓冲的时间
                let durationSeconds: TimeInterval = CMTimeGetSeconds(timeRange.duration)
                // 计算缓冲总时间
                let result: TimeInterval = startSeconds + durationSeconds;
                print("开始:\(startSeconds), 持续:\(durationSeconds), 总时间: \(result)")
                print("视频的加载进度是 \(durationSeconds / Double(self.totalDuration) * 100)")
            }
        }
    }
    
    @objc func didPlayToEndTime(notification: Notification) -> Void {
        
    }
    
    @objc func applicationDidEnterBackground() -> Void {
        self.pause()
    }
    
}

class AVPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
}
