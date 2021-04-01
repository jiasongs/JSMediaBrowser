//
//  VideoPlayerView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import AVKit
import JSCoreKit

@objc public enum Stauts: Int {
    case stopped = 0
    case ready
    case playing
    case paused
    case ended
    case failed
}

/// TODO：重写部分方法, 使之更加合理
@objc open class VideoPlayerView: BasisMediaView {
    
    @objc weak var delegate: VideoPlayerViewDelegate?
    
    @objc var url: URL? {
        didSet {
            if let url = self.url {
                if oldValue != url {
                    let item: AVPlayerItem = AVPlayerItem(url: url)
                    self.playerItem = item
                } else {
                    self.play()
                }
            }
        }
    }
    
    @objc var asset: AVAsset? {
        didSet {
            if let asset = self.asset {
                if oldValue != asset {
                    let item: AVPlayerItem = AVPlayerItem(asset: asset)
                    self.playerItem = item
                } else {
                    self.play()
                }
            }
        }
    }
    
    @objc var playerItem: AVPlayerItem? {
        willSet {
            self.removeObserverForPlayer()
        }
        didSet {
            if let playerItem = self.playerItem {
                if oldValue != playerItem {
                    self.player.replaceCurrentItem(with: playerItem)
                    self.addObserverForPlayer()
                } else {
                    self.addObserverForPlayer()
                    self.play()
                }
            }
        }
    }
    
    private lazy var player: AVPlayer = {
        let player = AVPlayer(playerItem: nil)
        self.playerLayer.player = player
        self.playerLayer.videoGravity = .resizeAspect
        return player
    }()
    
    private lazy var playerView: AVPlayerView = {
        return AVPlayerView()
    }()
    
    private var playerLayer: AVPlayerLayer {
        return self.playerView.layer as! AVPlayerLayer
    }
    
    open var currentTime: CGFloat {
        return CGFloat(CMTimeGetSeconds(self.player.currentTime()))
    }
    
    private(set) open var totalDuration: CGFloat = 0.0
    
    open var rate: CGFloat {
        get {
            return CGFloat(self.player.rate)
        }
        set {
            self.player.rate = Float(newValue)
        }
    }
    
    @objc open var isAutoPlay: Bool = true
    
    @objc open var status: Stauts = .stopped {
        didSet {
            if status == .ready {
                if let delegate = self.delegate, delegate.responds(to: #selector(VideoPlayerViewDelegate.videoPlayerViewDidReadyForDisplay(_:))) {
                    delegate.videoPlayerViewDidReadyForDisplay?(self)
                }
            } else if status == .failed {
                if let delegate = self.delegate, delegate.responds(to: #selector(VideoPlayerViewDelegate.videoPlayerView(_:didFailed:))) {
                    delegate.videoPlayerView?(self, didFailed: self.player.error as NSError?)
                }
            } else if status == .ended || status == .stopped {
                if let delegate = self.delegate, delegate.responds(to: #selector(VideoPlayerViewDelegate.videoPlayerViewDidPlayToEndTime(_:))) {
                    delegate.videoPlayerViewDidPlayToEndTime?(self)
                }
            }
        }
    }
    
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
        self.addSubview(self.playerView)
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
        self.playerView.js_frameApplyTransform = viewport
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
        if self.isReadyForDisplay {
            return self.convert(self.playerLayer.videoRect, from: contentView)
        } else {
            return self.convert(self.thumbImageView.frame, from: self.thumbImageView.superview)
        }
    }
    
    open var isReadyForDisplay: Bool {
        return self.playerLayer.isReadyForDisplay
    }
    
    open func play() -> Void {
        self.player.play()
        self.status = .playing
    }
    
    open func pause() -> Void {
        self.player.pause()
        self.status = .paused
    }
    
    open func reset() -> Void {
        self.pause()
        self.seek(to: 0)
    }
    
    open func releasePlayer() -> Void {
        self.playerItem = nil
        self.player.replaceCurrentItem(with: nil)
        self.status = .stopped
    }
    
    open func seek(to time: CGFloat, completionHandler: ((Bool) -> Void)? = nil) {
        let startTime: CMTime = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: player.currentTime().timescale)
        if !CMTIME_IS_INDEFINITE(startTime) && !CMTIME_IS_INVALID(startTime) {
            player.seek(to: startTime, toleranceBefore: CMTimeMake(value: 1, timescale: 1000), toleranceAfter: CMTimeMake(value: 1, timescale: 1000), completionHandler: { (finished) in
                if let block = completionHandler {
                    block(finished)
                }
            })
        }
    }
    
}

extension VideoPlayerView {
    
    func addObserverForPlayer() -> Void {
        if let playerItem = self.playerItem {
            /// status
            self.playerObservers.append(
                playerItem.observe(\.status, options: .new, changeHandler: { [weak self](playerItem: AVPlayerItem, change) in
                    if playerItem.status == .readyToPlay {
                        self?.totalDuration = CGFloat(CMTimeGetSeconds(playerItem.duration))
                        if let strongSelf = self, strongSelf.isAutoPlay {
                            strongSelf.player.play()
                        }
                    } else if playerItem.status == .failed {
                        self?.status = .failed
                    }
                })
            )
            /// isReadyForDisplay
            self.playerObservers.append(
                self.playerLayer.observe(\.isReadyForDisplay, options: .new, changeHandler: { [weak self](playerLayer: AVPlayerLayer, change) in
                    self?.status = .ready
                    /// 释放资源
                    self?.thumbImage = nil
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
                        let _: TimeInterval = startSeconds + durationSeconds
                        if let _ = self?.delegate {
                            
                        }
                    }
                })
            )
            /// progress
            self.playerTimeObservers.append(
                player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self](time: CMTime) in
                    if let strongSelf = self, let delegate = strongSelf.delegate, delegate.responds(to: #selector(VideoPlayerViewDelegate.videoPlayerView(_:progress:totalDuration:))) {
                        delegate.videoPlayerView?(strongSelf, progress: CGFloat(CMTimeGetSeconds(time)), totalDuration: strongSelf.totalDuration)
                    }
                })
            )
            /// PlayToEndTime
            self.playerCenterObservers.append(
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerItem, queue: OperationQueue.main) { [weak self](notification: Notification) in
                    self?.status = .ended
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
            self.player.removeTimeObserver(observer)
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
            NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main, using: { [weak self](notification: Notification) in
                if let strongSelf = self, strongSelf.status == .playing {
                    strongSelf.pause()
                }
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
