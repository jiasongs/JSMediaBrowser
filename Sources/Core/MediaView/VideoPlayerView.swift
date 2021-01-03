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
    
    @objc weak var delegate: VideoPlayerViewDelegate?
    
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
                self.player = AVPlayer(playerItem: playerItem)
                self.addObserverForPlayer()
            }
        }
    }
    private(set) var player: AVPlayer? {
        didSet {
            if let player = self.player {
                self.playerLayer?.player = player;
                self.playerLayer?.videoGravity = .resizeAspect
                self.setNeedsLayout()
            }
        }
    }
    
    @objc open var playerView: AVPlayerView?
    
    private var playerLayer: AVPlayerLayer? {
        return self.playerView?.layer as? AVPlayerLayer
    }
    
    open var currentTime: CGFloat {
        if let player = self.player {
            return CGFloat(CMTimeGetSeconds(player.currentTime()))
        }
        return 0
    }
    private(set) open var totalDuration: CGFloat = 0.0
    
    open var rate: CGFloat {
        get {
            return CGFloat(self.player?.rate ?? 0.0)
        }
        set {
            self.player?.rate = Float(newValue)
        }
    }
    
    open var isAutoPlay: Bool = true
    
    @objc var thumbImage: UIImage? {
        didSet {
            self.thumbImageView.image = self.thumbImage
            self.thumbImageView.isHidden = self.thumbImage == nil
            self.setNeedsLayout()
        }
    }
    
    private lazy var thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        self.sendSubviewToBack(imageView)
        return imageView
    }()
    
    private var isAddObserverForPlayer: Bool = false
    private var isAddObserverForSystem: Bool = false
    private var timeObserver: Any?
    
    override func didInitialize(frame: CGRect) -> Void {
        super.didInitialize(frame: frame)
        self.playerView = AVPlayerView()
        self.playerView?.contentMode = .scaleAspectFit
        self.addSubview(self.playerView!)
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
        let viewport = self.finalViewportRect
        self.playerView?.js_frameApplyTransform = viewport
        if let image = self.thumbImage {
            /// scaleAspectFit
            let horizontalRatio: CGFloat = viewport.width / image.size.width;
            let verticalRatio: CGFloat = viewport.height / image.size.height;
            let ratio: CGFloat = min(horizontalRatio, verticalRatio);
            let resizedSize: CGSize = CGSize(width: JSCGFlatSpecificScale(image.size.width * ratio, image.scale), height: JSCGFlatSpecificScale(image.size.height * ratio, image.scale))
            var rect: CGRect = CGRect(origin: CGPoint.zero, size: resizedSize)
            rect.origin.x = viewport.minX + (viewport.width - resizedSize.width) / 2.0
            rect.origin.y = viewport.minY + (viewport.height - resizedSize.height) / 2.0
            self.thumbImageView.js_frameApplyTransform = rect
        }
    }
    
}

extension VideoPlayerView {
    
    @objc open override var containerView: UIView? {
        return self
    }
    
    @objc open override var contentView: UIView? {
        return self.playerView
    }
    
    @objc open override var contentViewRectInZoomView: CGRect {
        guard let contentView = self.contentView else { return CGRect.zero }
        guard let playerLayer = self.playerLayer else { return CGRect.zero }
        if self.isReadyForDisplay {
            return self.convert(playerLayer.videoRect, from: contentView)
        } else {
            return self.convert(self.thumbImageView.frame, from: self.thumbImageView.superview)
        }
    }
    
    open var isReadyForDisplay: Bool {
        guard let playerLayer = self.playerLayer else { return false }
        return playerLayer.isReadyForDisplay
    }
    
    open func play() -> Void {
        self.player?.play()
    }
    
    open func pause() -> Void {
        self.player?.pause()
    }
    
    open func reset() -> Void {
        self.pause()
        self.playerItem = nil
        self.player = nil
        self.playerLayer?.player = nil
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
            self.playerLayer?.addObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), options: .new, context: nil)
            self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self](time: CMTime) in
                if let _ = self?.delegate {
                    
                }
                print("正在播放：\(CMTimeGetSeconds(time))")
            })
            NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        }
    }
    
    func removeObserverForPlayer() -> Void {
        if self.isAddObserverForPlayer {
            self.isAddObserverForPlayer = false
            self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
            self.playerLayer?.removeObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay))
            if let timeObserver = self.timeObserver  {
                self.player?.removeTimeObserver(timeObserver)
            }
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
        } else if keyPath == #keyPath(AVPlayerLayer.isReadyForDisplay) {
            /// 释放资源
            self.thumbImage = nil
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

open class AVPlayerView: UIView {
    
    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
}
