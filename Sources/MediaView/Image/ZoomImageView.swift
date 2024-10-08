//
//  ZoomImageView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import PhotosUI
import JSCoreKit

public class ZoomImageView: BasisMediaView {
    
    public var modifier: ZoomImageViewModifier?
    
    public var maximumZoomScale: CGFloat = 2.0 {
        didSet {
            self.scrollView.maximumZoomScale = self.maximumZoomScale
        }
    }
    
    public var image: UIImage? {
        didSet {
            guard self.image != nil || self.isImageViewInitialized else {
                return
            }
            if oldValue != self.image {
                if self.isLivePhotoViewInitialized {
                    self.livePhotoView.isHidden = true
                    self.livePhotoView.livePhoto = nil
                }
                self.imageView.isHidden = false
                self.imageView.image = self.image
                self.setNeedsRevertZoom()
            }
        }
    }
    
    public var livePhoto: PHLivePhoto? {
        didSet {
            guard self.livePhoto != nil || self.isLivePhotoViewInitialized else {
                return
            }
            if oldValue != self.livePhoto {
                if self.isImageViewInitialized {
                    self.imageView.isHidden = true
                    self.imageView.image = nil
                }
                self.livePhotoView.isHidden = false
                self.livePhotoView.livePhoto = self.livePhoto
                self.setNeedsRevertZoom()
            }
        }
    }
    
    public override var contentMode: UIView.ContentMode {
        didSet {
            if oldValue != self.contentMode {
                self.setNeedsRevertZoom()
            }
        }
    }
    
    public var enabledZoom: Bool = true
    
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = self.maximumZoomScale
        scrollView.scrollsToTop = false
        scrollView.delaysContentTouches = false
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private var isImageViewInitialized: Bool = false
    private lazy var imageView: UIImageView = {
        self.isImageViewInitialized = true
        var imageView: UIImageView = self.modifier?.imageView(in: self) ?? UIImageView()
        imageView.isHidden = true
        imageView.isAccessibilityElement = true
        self.scrollView.addSubview(imageView)
        return imageView
    }()
    
    private var isLivePhotoViewInitialized: Bool = false
    private lazy var livePhotoView: PHLivePhotoView = {
        self.isLivePhotoViewInitialized = true
        var livePhotoView: PHLivePhotoView = self.modifier?.livePhotoView(in: self) ?? PHLivePhotoView()
        livePhotoView.isHidden = true
        livePhotoView.delegate = self
        livePhotoView.isAccessibilityElement = true
        self.scrollView.addSubview(livePhotoView)
        return livePhotoView
    }()
    
    private weak var failGestureRecognizer: UIGestureRecognizer?
    private var isLivePhotoPlaying: Bool = false
    private var isNeededRevertZoom: Bool = false
    
    public override func didInitialize() {
        super.didInitialize()
        self.contentMode = .center
        
        self.addSubview(self.scrollView)
    }
    
    public override var containerView: UIView {
        return self.scrollView
    }
    
    public override var contentView: UIView? {
        if self.isDisplayImageView {
            return self.imageView
        } else if self.isDisplayLivePhotoView {
            return self.livePhotoView
        }
        return nil
    }
    
    public override var contentViewFrame: CGRect {
        guard let contentView = self.contentView else {
            return CGRect.zero
        }
        return self.convert(contentView.frame, from: contentView.superview)
    }
    
}

extension ZoomImageView {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.isEmpty {
            return
        }
        /// scrollView
        let previousSize = self.scrollView.bounds.size
        if previousSize != self.bounds.size {
            self.scrollView.js_frameApplyTransform = self.bounds
            self.setNeedsRevertZoom()
        }
        /// contentView
        if let contentView = self.contentView {
            var contentSize = CGSize.zero
            if self.isDisplayImageView, let imageSize = self.image?.size {
                contentSize = imageSize
            } else if self.isDisplayLivePhotoView, let livePhotoSize = self.livePhoto?.size {
                contentSize = livePhotoSize
            }
            let contentRect = JSCGRectApplyAffineTransformWithAnchorPoint(CGRect(origin: CGPoint.zero, size: contentSize),
                                                                          contentView.transform,
                                                                          contentView.layer.anchorPoint)
            contentView.frame = CGRect(origin: CGPoint.zero, size: contentRect.size)
        }
        
        self.revertZoomIfNeeded()
    }
    
}

extension ZoomImageView {
    
    public var minContentOffset: CGPoint {
        let scrollView: UIScrollView = self.scrollView
        let contentInset: UIEdgeInsets = scrollView.adjustedContentInset
        return CGPoint(x: -contentInset.left,
                       y: -contentInset.top)
    }
    
    public var maxContentOffset: CGPoint {
        let scrollView: UIScrollView = self.scrollView
        let contentInset: UIEdgeInsets = scrollView.adjustedContentInset
        return CGPoint(x: scrollView.contentSize.width + contentInset.right - scrollView.bounds.width,
                       y: scrollView.contentSize.height + contentInset.bottom - scrollView.bounds.height)
    }
    
    public func require(toFail otherGestureRecognizer: UIGestureRecognizer) {
        guard self.failGestureRecognizer != otherGestureRecognizer else {
            return
        }
        self.failGestureRecognizer = otherGestureRecognizer
        self.scrollView.panGestureRecognizer.require(toFail: otherGestureRecognizer)
        self.scrollView.pinchGestureRecognizer?.require(toFail: otherGestureRecognizer)
    }
    
}

extension ZoomImageView {
    
    public var isDisplayImageView: Bool {
        return self.isImageViewInitialized && !self.imageView.isHidden
    }
    
    public var isDisplayLivePhotoView: Bool {
        return self.isLivePhotoViewInitialized && !self.livePhotoView.isHidden
    }
    
    var isAnimating: Bool {
        if self.isDisplayImageView {
            return self.imageView.isAnimating
        } else if self.isDisplayLivePhotoView {
            return self.isLivePhotoPlaying
        }
        return false
    }
    
    public func startAnimating() {
        guard !self.isAnimating else {
            return
        }
        if self.isDisplayImageView {
            self.imageView.startAnimating()
        } else if self.isDisplayLivePhotoView {
            self.livePhotoView.startPlayback(with: .full)
        }
    }
    
    public func stopAnimating() {
        guard self.isAnimating else {
            return
        }
        if self.isDisplayImageView {
            self.imageView.stopAnimating()
        } else if self.isDisplayLivePhotoView {
            self.livePhotoView.stopPlayback()
        }
    }
    
    public var minimumZoomScale: CGFloat {
        var mediaSize: CGSize = CGSize.zero
        if let image = self.image {
            mediaSize = image.size
        } else if let livePhoto = self.livePhoto {
            mediaSize = livePhoto.size
        }
        var minScale: CGFloat = 1.0
        if self.contentView == nil || mediaSize.width <= 0 || mediaSize.height <= 0 {
            minScale = 1.0
        } else {
            let viewport: CGRect = self.calculateViewportRect
            var contentMode = self.contentMode
            let scaleX: CGFloat = viewport.width / mediaSize.width
            let scaleY: CGFloat = viewport.height / mediaSize.height
            let finalHeight: CGFloat = mediaSize.width > viewport.width ? viewport.width * (mediaSize.height / mediaSize.width) : mediaSize.height
            if finalHeight > viewport.height {
                contentMode = .scaleAspectFill
            }
            if contentMode == .scaleAspectFit {
                minScale = min(scaleX, scaleY)
            } else if contentMode == .scaleAspectFill {
                minScale = max(scaleX, scaleY)
            } else if contentMode == .center {
                if scaleX >= 1 && scaleY >= 1 {
                    minScale = 1.0
                } else {
                    minScale = min(scaleX, scaleY)
                }
            }
        }
        return minScale
    }
    
    public var zoomScale: CGFloat {
        return self.scrollView.zoomScale
    }
    
    public func setZoom(scale: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: JSCoreHelper.animationOptionsCurveOut, animations: {
                self.scrollView.zoomScale = scale
            }, completion: nil)
        } else {
            self.scrollView.zoomScale = scale
        }
    }
    
    public func zoom(to point: CGPoint, scale: CGFloat = 3.0, animated: Bool) {
        guard scale > 0 else {
            return
        }
        let minimumZoomScale: CGFloat = self.minimumZoomScale
        var zoomRect: CGRect = CGRect.zero
        zoomRect.size.width = self.scrollView.frame.width / scale / minimumZoomScale
        zoomRect.size.height = self.scrollView.frame.height / scale / minimumZoomScale
        zoomRect.origin.x = point.x - zoomRect.width / 2
        zoomRect.origin.y = point.y - zoomRect.height / 2
        self.zoom(to: zoomRect, animated: animated)
    }
    
    public func zoom(to rect: CGRect, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: JSCoreHelper.animationOptionsCurveOut, animations: {
                self.scrollView.zoom(to: rect, animated: false)
            }, completion: nil)
        } else {
            self.scrollView.zoom(to: rect, animated: false)
        }
    }
    
    public func revertZooming() {
        if self.bounds.isEmpty {
            return
        }
        let enabledZoom: Bool = self.enabledZoom
        let minimumZoomScale: CGFloat = self.minimumZoomScale
        let maximumZoomScale: CGFloat = max(enabledZoom ? self.maximumZoomScale : minimumZoomScale, minimumZoomScale)
        let shouldFireDidZoomingManual: Bool = self.zoomScale == minimumZoomScale
        self.scrollView.panGestureRecognizer.isEnabled = enabledZoom
        self.scrollView.pinchGestureRecognizer?.isEnabled = enabledZoom
        self.scrollView.minimumZoomScale = minimumZoomScale
        self.scrollView.maximumZoomScale = maximumZoomScale
        /// 重置ZoomScale
        self.setZoom(scale: minimumZoomScale, animated: false)
        /// 手动触发一次缩放
        if shouldFireDidZoomingManual {
            self.handleDidEndZooming()
        }
        /// 重置ContentOffset
        self.revertContentOffset(animated: false)
    }
    
}

extension ZoomImageView {
    
    private var calculateViewportRect: CGRect {
        let resultRect = self.modifier?.viewportRect(in: self) ?? CGRect.zero
        return !resultRect.isEmpty ? resultRect : self.finalViewportRect
    }
    
    private func setNeedsRevertZoom() {
        self.isNeededRevertZoom = true
        self.setNeedsLayout()
    }
    
    private func revertZoomIfNeeded() {
        guard self.isNeededRevertZoom else {
            return
        }
        self.isNeededRevertZoom = false
        self.revertZooming()
    }
    
    private func handleDidEndZooming() {
        guard let contentView = self.contentView else {
            return
        }
        let viewport: CGRect = self.calculateViewportRect
        let contentViewFrame: CGRect = self.contentViewFrame
        var contentInset: UIEdgeInsets = UIEdgeInsets.zero
        contentInset.top = viewport.minY
        contentInset.left = viewport.minX
        contentInset.right = self.scrollView.bounds.width - viewport.maxX
        contentInset.bottom = self.scrollView.bounds.height - viewport.maxY
        if viewport.height >= contentViewFrame.height {
            contentInset.top = floor(viewport.midY - contentViewFrame.height / 2.0)
            contentInset.bottom = floor(self.scrollView.bounds.height - viewport.midY - contentViewFrame.height / 2.0)
        }
        if viewport.width >= contentViewFrame.width {
            contentInset.left = floor(viewport.midX - contentViewFrame.width / 2.0)
            contentInset.right = floor(self.scrollView.bounds.width - viewport.midX - contentViewFrame.width / 2.0)
        }
        self.scrollView.contentInset = contentInset
        self.scrollView.contentSize = contentView.frame.size
    }
    
    private func revertContentOffset(animated: Bool) {
        var x: CGFloat = self.scrollView.contentOffset.x
        var y: CGFloat = self.scrollView.contentOffset.y
        let viewport: CGRect = self.calculateViewportRect
        if let contentView = self.contentView, !viewport.isEmpty {
            if viewport.width < contentView.frame.width {
                x = (contentView.frame.width - viewport.width) / 2 - viewport.minX
            }
            if viewport.height < contentView.frame.height {
                y = -self.scrollView.contentInset.top
            }
        }
        self.scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
    
}

extension ZoomImageView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.handleDidEndZooming()
    }
    
}

extension ZoomImageView: PHLivePhotoViewDelegate {
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.isLivePhotoPlaying = true
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.isLivePhotoPlaying = false
    }
    
}
