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
                if self.player != nil {
                    self.player?.replaceCurrentItem(with: self.playerItem)
                } else {
                    self.player = AVPlayer(playerItem: playerItem)
                }
                self.addObserverForPlayer()
            }
        }
    }
    private(set) var player: AVPlayer? {
        didSet {
            if let player = self.player {
                self.playerLayer?.player = player
                self.playerLayer?.videoGravity = .resizeAspect
                self.setNeedsLayout()
            }
        }
    }
    
    fileprivate var playerView: AVPlayerView?
    
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
    
    private var playerObservers = Array<NSKeyValueObservation>()
    private var playerCenterObservers = Array<NSObjectProtocol>()
    private var playerTimeObservers = Array<Any>()
    private var systemObservers = Array<NSObjectProtocol>()
    
    override func didInitialize(frame: CGRect) -> Void {
        super.didInitialize(frame: frame)
        self.playerView = AVPlayerView()
        self.addSubview(self.playerView!)
        /// 系统的监听
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
            let horizontalRatio: CGFloat = viewport.width / image.size.width
            let verticalRatio: CGFloat = viewport.height / image.size.height
            let ratio: CGFloat = min(horizontalRatio, verticalRatio)
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
    
    @objc open override var contentViewFrame: CGRect {
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
    
    open func seek(to time: CGFloat) {
        guard let player = self.player else { return }
        let startTime: CMTime = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: player.currentTime().timescale)
        player.seek(to: CMTime(seconds: Double(startTime.value), preferredTimescale: CMTimeScale.zero), toleranceBefore: CMTimeMake(value: 1, timescale: 1000), toleranceAfter: CMTimeMake(value: 1, timescale: 1000), completionHandler: { (finished) in
            if (finished) {
                self.play()
            }
        })
    }
    
}

extension VideoPlayerView {
    
    func addObserverForPlayer() -> Void {
        if let playerItem = self.playerItem, let player = self.player, let playerLayer = self.playerLayer {
            /// status
            self.playerObservers.append(
                playerItem.observe(\.status, options: .new, changeHandler: { [weak self](playerItem: AVPlayerItem, change) in
                    if playerItem.status == .readyToPlay {
                        self?.totalDuration = CGFloat(CMTimeGetSeconds(playerItem.duration))
                        if let strongSelf = self, strongSelf.isAutoPlay {
                            strongSelf.player?.play()
                        }
                    }
                })
            )
            /// loadedTimeRanges
            self.playerObservers.append(
                playerItem.observe(\.loadedTimeRanges, options: .new, changeHandler: { [weak self](playerItem: AVPlayerItem, change) in
                    let loadedTimeRanges: Array<NSValue> = playerItem.loadedTimeRanges
                    if loadedTimeRanges.count > 0 {
                        // 获取缓冲区域
                        let timeRange: CMTimeRange =  loadedTimeRanges.first?.timeRangeValue ?? CMTimeRange.zero
                        // 开始的时间
                        let startSeconds: TimeInterval = CMTimeGetSeconds(timeRange.start)
                        // 表示已经缓冲的时间
                        let durationSeconds: TimeInterval = CMTimeGetSeconds(timeRange.duration)
                        // 计算缓冲总时间
                        let result: TimeInterval = startSeconds + durationSeconds
                        print("开始:\(startSeconds), 持续:\(durationSeconds), 总时间: \(result)")
                        print("视频的加载进度是 \(durationSeconds / Double(self?.totalDuration ?? 1) * 100)")
                    }
                })
            )
            /// isReadyForDisplay
            self.playerObservers.append(
                playerLayer.observe(\.isReadyForDisplay, options: .new, changeHandler: { [weak self](playerLayer: AVPlayerLayer, change) in
                    /// 释放资源
                    self?.thumbImage = nil
                })
            )
            /// progress
            self.playerTimeObservers.append(
                player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self](time: CMTime) in
                    if let _ = self?.delegate {
                        
                    }
                    print("正在播放：\(CMTimeGetSeconds(time))")
                })
            )
            /// PlayToEndTime
            self.playerCenterObservers.append(
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerItem, queue: OperationQueue.main) { [weak self](notification: Notification) in
                    if let _ = self?.delegate {
                        
                    }
                }
            )
        }
    }
    
    func removeObserverForPlayer() -> Void {
        /// 移除playerObservers
        for observer in self.playerObservers {
            observer.invalidate()
        }
        self.playerObservers.removeAll()
        /// 移除playerTimeObservers
        for observer in self.playerTimeObservers {
            self.player?.removeTimeObserver(observer)
        }
        self.playerTimeObservers.removeAll()
        /// 移除playerCenterObservers
        for observer in self.self.playerCenterObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.playerCenterObservers.removeAll()
    }
    
    func addObserverForSystem() -> Void {
        self.systemObservers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main, using: { [weak self](notification: Notification) in
                self?.pause()
            })
        )
    }
    
    func removeObserverForSystem() -> Void {
        for observer in self.systemObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.systemObservers.removeAll()
    }
    
}

fileprivate class AVPlayerView: UIView {
    
    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
}
