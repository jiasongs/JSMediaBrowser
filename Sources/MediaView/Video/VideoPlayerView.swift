//
//  VideoPlayerView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import AVKit
import JSCoreKit

@objc(JSMediaBrowserVideoPlayerStauts)
public enum Stauts: Int {
    case stopped = 0
    case ready
    case playing
    case paused
    case ended
    case failed
}

@objc(JSMediaBrowserVideoPlayerView)
open class VideoPlayerView: BasisMediaView {
    
    @objc weak var delegate: VideoPlayerViewDelegate?
    
    @objc var url: URL? {
        didSet {
            if let url = self.url {
                if oldValue != url {
                    let item: AVPlayerItem = AVPlayerItem(url: url)
                    self.playerItem = item
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
                }
            }
        }
    }
    
    @objc var playerItem: AVPlayerItem? {
        willSet {
            if newValue != nil && newValue != self.playerItem {
                self.removeObserverForPlayerItem()
            }
        }
        didSet {
            if let playerItem = self.playerItem {
                if oldValue != playerItem {
                    self.addObserverForPlayerItem()
                    self.player.replaceCurrentItem(with: playerItem)
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
        let playerView = AVPlayerView()
        return playerView
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
    
    private var playerItemObservers = Array<NSKeyValueObservation>()
    private var playerObservers = Array<NSKeyValueObservation>()
    private var playerItemCenterObservers = Array<NSObjectProtocol>()
    private var playerTimeObservers = Array<Any>()
    private var systemObservers = Array<NSObjectProtocol>()
    
    open override func didInitialize(frame: CGRect) -> Void {
        super.didInitialize(frame: frame)
        self.addSubview(self.playerView)
        self.addObserverForSystem()
        self.addObserverForPlayer()
    }
    
    deinit {
        self.removeObserverForPlayerItem()
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
    
    @objc open override var containerView: UIView {
        return self
    }
    
    @objc open override var contentView: UIView {
        return self.playerView
    }
    
    @objc open override var contentViewFrame: CGRect {
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
        if self.status == .ready || self.status == .paused {
            self.player.play()
            self.status = .playing
            self.releaseThumbImage()
        }
    }
    
    open func pause() -> Void {
        self.player.pause()
        self.status = .paused
    }
    
    open func reset() -> Void {
        self.player.pause()
        self.seek(to: 0) { (finished) in
            self.status = .ready
        }
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
    
    private func releaseThumbImage() -> Void {
        if self.thumbImage != nil && self.isReadyForDisplay {
            self.thumbImage = nil
        }
    }
    
}

extension VideoPlayerView {
    
    func addObserverForPlayer() -> Void {
        /// progress
        self.playerTimeObservers.append(
            self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self](time: CMTime) in
                if let strongSelf = self, let delegate = strongSelf.delegate, delegate.responds(to: #selector(VideoPlayerViewDelegate.videoPlayerView(_:progress:totalDuration:))) {
                    delegate.videoPlayerView?(strongSelf, progress: CGFloat(CMTimeGetSeconds(time)), totalDuration: strongSelf.totalDuration)
                }
            })
        )
        /// isReadyForDisplay
        self.playerObservers.append(
            self.playerLayer.observe(\.isReadyForDisplay, options: .new, changeHandler: { [weak self](playerLayer: AVPlayerLayer, change) in
                if self?.playerItem?.status == .readyToPlay {
                    self?.releaseThumbImage()
                }
            })
        )
    }
    
    func addObserverForPlayerItem() -> Void {
        if let playerItem = self.playerItem {
            /// status
            self.playerItemObservers.append(
                playerItem.observe(\.status, options: .new, changeHandler: { [weak self](playerItem: AVPlayerItem, change) in
                    guard let strongSelf = self else { return }
                    if playerItem.status == .readyToPlay {
                        self?.status = .ready
                        self?.totalDuration = CGFloat(CMTimeGetSeconds(playerItem.duration))
                        self?.releaseThumbImage()
                        if strongSelf.isAutoPlay {
                            strongSelf.play()
                        }
                    } else if playerItem.status == .failed {
                        self?.status = .failed
                    }
                })
            )
            /// PlayToEndTime
            self.playerItemCenterObservers.append(
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: OperationQueue.main) { [weak self](notification: Notification) in
                    guard let strongSelf = self else { return }
                    if strongSelf.playerItem == notification.object as? AVPlayerItem {
                        self?.status = .ended
                    }
                }
            )
            /// loadedTimeRanges
            self.playerItemObservers.append(
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
    }
    
    func removeObserverForPlayerItem() -> Void {
        /// 移除playerItemObservers
        for observer in self.playerItemObservers {
            observer.invalidate()
        }
        self.playerItemObservers.removeAll()
        /// 移除playerItemCenterObservers
        for observer in self.self.playerItemCenterObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.playerItemCenterObservers.removeAll()
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
