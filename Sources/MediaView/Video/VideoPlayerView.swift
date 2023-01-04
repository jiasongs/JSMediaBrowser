//
//  VideoPlayerView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import AVKit
import JSCoreKit

public enum Stauts: Int {
    case stopped = 0
    case ready
    case playing
    case paused
    case ended
    case failed
}

public class VideoPlayerView: BasisMediaView {
    
    public weak var delegate: VideoPlayerViewDelegate?
    
    public var url: URL? {
        didSet {
            if let url = self.url {
                if oldValue != url {
                    let item: AVPlayerItem = AVPlayerItem(url: url)
                    self.playerItem = item
                }
            }
        }
    }
    
    public var asset: AVAsset? {
        didSet {
            if let asset = self.asset {
                if oldValue != asset {
                    let item: AVPlayerItem = AVPlayerItem(asset: asset)
                    self.playerItem = item
                }
            }
        }
    }
    
    public var playerItem: AVPlayerItem? {
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
    
    public var currentTime: CGFloat {
        return CGFloat(CMTimeGetSeconds(self.player.currentTime()))
    }
    
    private(set) public var totalDuration: CGFloat = 0.0
    
    public var rate: CGFloat {
        get {
            return CGFloat(self.player.rate)
        }
        set {
            self.player.rate = Float(newValue)
        }
    }
    
    public var isAutoPlay: Bool = true
    
    public var status: Stauts = .stopped {
        didSet {
            if status == .ready {
                self.delegate?.didReadyForDisplay(self)
            } else if status == .failed {
                self.delegate?.didFailed(self, error: self.player.error as NSError?)
            } else if status == .ended || status == .stopped {
                self.delegate?.didPlayToEndTime(self)
            }
        }
    }
    
    public var thumbImage: UIImage? {
        didSet {
            self.thumbImageView.image = self.thumbImage
            self.thumbImageView.isHidden = self.thumbImage == nil
            self.setNeedsLayout()
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
    
    private lazy var thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        self.sendSubviewToBack(imageView)
        return imageView
    }()
    
    fileprivate var playerItemObservers = [NSKeyValueObservation]()
    fileprivate var playerObservers = [NSKeyValueObservation]()
    fileprivate var playerItemCenterObservers = [AnyObject]()
    fileprivate var playerTimeObservers = [Any]()
    fileprivate var systemObservers = [AnyObject]()
    
    public override func didInitialize() {
        super.didInitialize()
        self.addSubview(self.playerView)
        self.addObserverForSystem()
        self.addObserverForPlayer()
    }
    
    public override var containerView: UIView {
        return self
    }
    
    public override var contentView: UIView? {
        return self.playerView
    }
    
    public override var contentViewFrame: CGRect {
        if self.isReadyForDisplay {
            return self.convert(self.playerLayer.videoRect, from: self.playerView)
        } else {
            return self.convert(self.thumbImageView.frame, from: self.thumbImageView.superview)
        }
    }
    
    deinit {
        self.removeObserverForPlayerItem()
        self.removeObserverForPlayer()
        self.removeObserverForSystem()
    }
    
}

extension VideoPlayerView {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let viewport = self.finalViewportRect
        self.playerView.js_frameApplyTransform = viewport
        if let image = self.thumbImage {
            /// scaleAspectFit
            let horizontalRatio: CGFloat = viewport.width / image.size.width
            let verticalRatio: CGFloat = viewport.height / image.size.height
            let ratio: CGFloat = min(horizontalRatio, verticalRatio)
            let resizedSize: CGSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
            var rect: CGRect = CGRect(origin: CGPoint.zero, size: resizedSize)
            rect.origin.x = viewport.minX + (viewport.width - resizedSize.width) / 2.0
            rect.origin.y = viewport.minY + (viewport.height - resizedSize.height) / 2.0
            self.thumbImageView.js_frameApplyTransform = rect
        }
    }
    
}

extension VideoPlayerView {
    
    public var isReadyForDisplay: Bool {
        return self.playerLayer.isReadyForDisplay
    }
    
    public func play() {
        if self.status == .ready || self.status == .paused {
            self.player.play()
            self.status = .playing
            self.releaseThumbImage()
        }
    }
    
    public func pause() {
        self.player.pause()
        self.status = .paused
    }
    
    public func reset() {
        self.player.pause()
        self.seek(to: 0) { (finished) in
            self.status = .ready
        }
    }
    
    public func releasePlayer() {
        self.playerItem = nil
        self.player.replaceCurrentItem(with: nil)
        self.status = .stopped
    }
    
    public func seek(to time: CGFloat, completionHandler: ((Bool) -> Void)? = nil) {
        let startTime: CMTime = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: player.currentTime().timescale)
        if !CMTIME_IS_INDEFINITE(startTime) && !CMTIME_IS_INVALID(startTime) {
            player.seek(to: startTime, toleranceBefore: CMTimeMake(value: 1, timescale: 1000), toleranceAfter: CMTimeMake(value: 1, timescale: 1000), completionHandler: { (finished) in
                completionHandler?(finished)
            })
        }
    }
    
}

extension VideoPlayerView {
    
    private func releaseThumbImage() {
        if self.thumbImage != nil && self.isReadyForDisplay {
            self.thumbImage = nil
        }
    }
    
}

extension VideoPlayerView {
    
    func addObserverForPlayer() {
        /// progress
        self.playerTimeObservers.append(
            self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self](time: CMTime) in
                guard let self = self else {
                    return
                }
                
                self.delegate?.periodicTime(CGFloat(CMTimeGetSeconds(time)), totalDuration: self.totalDuration, in: self)
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
    
    func addObserverForPlayerItem() {
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
                playerItem.observe(\.loadedTimeRanges, options: .new, changeHandler: { (playerItem: AVPlayerItem, change) in
                    let loadedTimeRanges: [NSValue] = playerItem.loadedTimeRanges
                    if loadedTimeRanges.count > 0 {
                        // 获取缓冲区域
                        let timeRange: CMTimeRange =  loadedTimeRanges.first?.timeRangeValue ?? CMTimeRange.zero
                        // 开始的时间
                        let startSeconds: TimeInterval = CMTimeGetSeconds(timeRange.start)
                        // 表示已经缓冲的时间
                        let durationSeconds: TimeInterval = CMTimeGetSeconds(timeRange.duration)
                        // 计算缓冲总时间
                        let _: TimeInterval = startSeconds + durationSeconds
                    }
                })
            )
        }
    }
    
    func removeObserverForPlayer() {
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
    
    func removeObserverForPlayerItem() {
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
    
    func addObserverForSystem() {
        self.systemObservers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main, using: { [weak self](notification: Notification) in
                if let strongSelf = self, strongSelf.status == .playing {
                    strongSelf.pause()
                }
            })
        )
    }
    
    func removeObserverForSystem() {
        for observer in self.systemObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.systemObservers.removeAll()
    }
    
}

fileprivate class AVPlayerView: UIView {
    
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
}
