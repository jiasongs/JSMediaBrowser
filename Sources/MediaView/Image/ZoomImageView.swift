//
//  ZoomImageView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import PhotosUI
import JSCoreKit

open class ZoomImageView: BasisMediaView {
    
    weak var delegate: ZoomImageViewDelegate?
    
    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = self.maximumZoomScale
        scrollView.scrollsToTop = false
        scrollView.delaysContentTouches = false
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    private var isImageViewInitialized: Bool = false
    private(set) lazy var imageView: UIImageView = {
        isImageViewInitialized = true
        var imageView: UIImageView = self.delegate?.zoomImageViewLazyBuildImageView(self) ?? UIImageView()
        imageView.isHidden = true
        imageView.isAccessibilityElement = true
        self.scrollView.addSubview(imageView)
        return imageView
    }()
    
    private var isLivePhotoViewInitialized: Bool = false
    private(set) lazy var livePhotoView: PHLivePhotoView = {
        isLivePhotoViewInitialized = true
        var livePhotoView: PHLivePhotoView = self.delegate?.zoomImageViewLazyBuildLivePhotoView(self) ?? PHLivePhotoView()
        livePhotoView.isHidden = true
        livePhotoView.delegate = self
        livePhotoView.isAccessibilityElement = true
        self.scrollView.addSubview(livePhotoView)
        return livePhotoView
    }()
    
    public var maximumZoomScale: CGFloat = 2.0 {
        didSet {
            self.scrollView.maximumZoomScale = maximumZoomScale
        }
    }
    
    public weak var image: UIImage? {
        didSet {
            if self.image == nil && !self.isImageViewInitialized {
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
    
    public weak var livePhoto: PHLivePhoto? {
        didSet {
            if self.livePhoto == nil && !self.isLivePhotoViewInitialized {
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
    
    public var enabledZoom: Bool = true
    
    fileprivate weak var failGestureRecognizer: UIGestureRecognizer?
    fileprivate var isLivePhotoPlaying: Bool = false
    fileprivate var isNeededRevertZoom: Bool = false
    
    open override func didInitialize(frame: CGRect) {
        super.didInitialize(frame: frame)
        self.contentMode = .center
        
        self.addSubview(self.scrollView)
    }
    
    open override var containerView: UIView {
        return self.scrollView
    }
    
    open override var contentView: UIView? {
        if self.isDisplayImageView {
            return self.imageView
        } else if self.isDisplayLivePhotoView {
            return self.livePhotoView
        }
        return nil
    }
    
    open override var contentViewFrame: CGRect {
        guard let contentView = self.contentView else {
            return CGRect.zero
        }
        return self.convert(contentView.frame, from: contentView.superview)
    }
    
    open override var finalViewportRect: CGRect {
        var resultRect = super.finalViewportRect
        if let viewportRect = self.delegate?.zoomImageView(self, finalViewportRect: resultRect), !viewportRect.isEmpty {
            resultRect = viewportRect
        }
        return resultRect
    }
    
}

extension ZoomImageView {
    
    open override func layoutSubviews() {
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
    
    open override var contentMode: UIView.ContentMode {
        didSet {
            if oldValue != self.contentMode {
                self.setNeedsRevertZoom()
            }
        }
    }
    
}

extension ZoomImageView {
    
    public var isDisplayImageView: Bool {
        return isImageViewInitialized && !self.imageView.isHidden
    }
    
    public var isDisplayLivePhotoView: Bool {
        return isLivePhotoViewInitialized && !self.livePhotoView.isHidden
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
    
}

extension ZoomImageView {
    
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
            let viewport: CGRect = self.finalViewportRect
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
    
    public func setZoom(scale: CGFloat, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: AnimationOptionsCurveOut, animations: {
                self.scrollView.zoomScale = scale
            }, completion: nil)
        } else {
            self.scrollView.zoomScale = scale
        }
    }
    
    public func zoom(to point: CGPoint, scale: CGFloat = 3.0, animated: Bool = true) {
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
    
    public func zoom(to rect: CGRect, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: AnimationOptionsCurveOut, animations: {
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
    
    fileprivate func setNeedsRevertZoom() {
        self.isNeededRevertZoom = true
        self.setNeedsLayout()
    }
    
    fileprivate func revertZoomIfNeeded() {
        if self.isNeededRevertZoom {
            self.isNeededRevertZoom = false
            self.revertZooming()
        }
    }
    
    fileprivate func handleDidEndZooming() {
        guard let contentView = self.contentView else {
            return
        }
        let viewport: CGRect = self.finalViewportRect
        let contentViewFrame: CGRect = self.contentViewFrame
        var contentInset: UIEdgeInsets = UIEdgeInsets.zero
        contentInset.top = viewport.minY
        contentInset.left = viewport.minX
        contentInset.right = scrollView.bounds.width - viewport.maxX
        contentInset.bottom = scrollView.bounds.height - viewport.maxY
        if viewport.height >= contentViewFrame.height {
            contentInset.top = floor(viewport.midY - contentViewFrame.height / 2.0)
            contentInset.bottom = floor(scrollView.bounds.height - viewport.midY - contentViewFrame.height / 2.0)
        }
        if viewport.width >= contentViewFrame.width {
            contentInset.left = floor(viewport.midX - contentViewFrame.width / 2.0)
            contentInset.right = floor(scrollView.bounds.width - viewport.midX - contentViewFrame.width / 2.0)
        }
        self.scrollView.contentInset = contentInset
        self.scrollView.contentSize = contentView.frame.size
    }
    
}

extension ZoomImageView {
    
    public var minContentOffset: CGPoint {
        let scrollView: UIScrollView = self.scrollView
        let contentInset: UIEdgeInsets = scrollView.contentInset
        return CGPoint(x: -contentInset.left,
                       y: -contentInset.top)
    }
    
    public var maxContentOffset: CGPoint {
        let scrollView: UIScrollView = self.scrollView
        let contentInset: UIEdgeInsets = scrollView.contentInset
        return CGPoint(x: scrollView.contentSize.width + contentInset.right - scrollView.bounds.width,
                       y: scrollView.contentSize.height + contentInset.bottom - scrollView.bounds.height)
    }
    
    public func revertContentOffset(animated: Bool = true) {
        var x: CGFloat = self.scrollView.contentOffset.x
        var y: CGFloat = self.scrollView.contentOffset.y
        let viewport: CGRect = self.finalViewportRect
        if let contentView = self.contentView, !viewport.isEmpty {
            if viewport.width < contentView.frame.width {
                x = (contentView.frame.width - viewport.width) / 2 - viewport.minX
            }
            if viewport.height < contentView.frame.height {
                y = -scrollView.contentInset.top
            }
        }
        self.scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
    
    public func require(toFail otherGestureRecognizer: UIGestureRecognizer) {
        guard self.failGestureRecognizer != otherGestureRecognizer else {
            return
        }
        self.failGestureRecognizer = otherGestureRecognizer
        self.scrollView.panGestureRecognizer.require(toFail: otherGestureRecognizer)
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
