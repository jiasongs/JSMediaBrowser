//
//  VideoPlayerView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import MediaPlayer
import JSCoreKit

open class VideoPlayerView: UIView {
    
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
    lazy var playerView: AVPlayerView  = {
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    func didInitialize(frame: CGRect) -> Void {
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
            let safeAreaInsets: UIEdgeInsets = JSCoreHelper.safeAreaInsetsForDeviceWithNotch()
            let size: CGSize = CGSize(width: min(self.bounds.width, 700), height: self.bounds.height)
            let offsetX = (self.bounds.width - size.width) / 2
            let top = safeAreaInsets.top
            let left = max(safeAreaInsets.left, offsetX)
            let bottom = safeAreaInsets.bottom
            let right = safeAreaInsets.right
            self.playerView.frame = CGRect(x: left, y: top, width: min(size.width, self.bounds.width - left - right), height: size.height - top - bottom)
        }
    }

}

extension VideoPlayerView {
    
    open func play() -> Void {
        self.player?.play()
    }

    open func pause() -> Void {
        self.player?.pause()
    }
    
    open func reset() -> Void {
        self.pause()
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
        
    }
    
}

class AVPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
}
