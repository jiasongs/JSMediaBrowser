//
//  ZoomImageView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import PhotosUI
import JSCoreKit

@objc(MediaBrowserZoomImageView)
open class ZoomImageView: BaseMediaView {
    
    @objc weak var delegate: ZoomImageViewDelegate?
    
    @objc private var scrollView: UIScrollView?
    
    private var isImageViewInitialized: Bool = false
    @objc private lazy var imageView: UIImageView = {
        isImageViewInitialized = true
        var imageView: UIImageView
        if let delegate = self.delegate, delegate.responds(to: #selector(ZoomImageViewDelegate.zoomImageViewLazyBuildImageView(_:))) {
            imageView = delegate.zoomImageViewLazyBuildImageView!(self)
        } else {
            imageView = UIImageView()
        }
        imageView.isHidden = true
        scrollView?.addSubview(imageView)
        return imageView
    }()
    
    private var isLivePhotoViewInitialized: Bool = false
    @objc private lazy var livePhotoView: PHLivePhotoView = {
        isLivePhotoViewInitialized = true
        var livePhotoView: PHLivePhotoView
        if let delegate = self.delegate, delegate.responds(to: #selector(ZoomImageViewDelegate.zoomImageViewLazyBuildLivePhotoView(_:))) {
            livePhotoView = delegate.zoomImageViewLazyBuildLivePhotoView!(self)
        } else {
            livePhotoView = PHLivePhotoView()
        }
        livePhotoView.isHidden = true
        livePhotoView.delegate = self
        scrollView?.addSubview(livePhotoView)
        return livePhotoView
    }()
    
    @objc public var maximumZoomScale: CGFloat = 2.0 {
        didSet {
            self.scrollView?.maximumZoomScale = maximumZoomScale
        }
    }
    
    @objc public weak var image: UIImage? {
        didSet {
            if image == nil && !isImageViewInitialized {
                return
            }
            if isLivePhotoViewInitialized {
                self.livePhotoView.isHidden = true
                self.livePhotoView.livePhoto = nil
            }
            self.imageView.isHidden = false
            self.imageView.image = image
            self.imageView.js_frameApplyTransform = CGRect(origin: CGPoint.zero, size: image?.size ?? CGSize.zero)
            self.revertZooming()
        }
    }
    
    @objc public weak var livePhoto: PHLivePhoto? {
        didSet {
            if livePhoto == nil && !isLivePhotoViewInitialized {
                return
            }
            if isImageViewInitialized {
                self.imageView.isHidden = true
                self.imageView.image = nil
            }
            self.livePhotoView.isHidden = false
            self.livePhotoView.livePhoto = livePhoto
            self.livePhotoView.js_frameApplyTransform = CGRect(origin: CGPoint.zero, size: livePhoto?.size ?? CGSize.zero)
            self.revertZooming()
        }
    }
    private var isLivePhotoPlaying: Bool = false
    
    @objc public var enabledZoom: Bool = true

    override func didInitialize(frame: CGRect) -> Void {
        super.didInitialize(frame: frame)
        self.contentMode = .center
        
        self.scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.minimumZoomScale = 0
        self.scrollView?.maximumZoomScale = self.maximumZoomScale
        self.scrollView?.scrollsToTop = false
        self.scrollView?.delaysContentTouches = false
        self.scrollView?.delegate = self
        if #available(iOS 11.0, *) {
            self.scrollView?.contentInsetAdjustmentBehavior = .never
        }
        self.addSubview(self.scrollView!)
    }
    
}

extension ZoomImageView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.isEmpty {
            return
        }
        self.scrollView?.js_frameApplyTransform = self.bounds
    }
    
    open override var frame: CGRect {
        didSet {
            if !oldValue.size.equalTo(self.frame.size) {
                self.revertZooming()
            }
        }
    }
    
    open override var contentMode: UIView.ContentMode {
        didSet {
            if oldValue != self.contentMode {
                self.revertZooming()
            }
        }
    }
    
}

extension ZoomImageView {
    
    open override var containerView: UIView? {
        return self.scrollView
    }
    
    @objc open override var contentView: UIView? {
        if self.isDisplayImageView {
            return self.imageView
        } else if self.isDisplayLivePhotoView {
            return self.livePhotoView
        }
        return nil
    }
    
    @objc open override var contentViewFrame: CGRect {
        guard let contentView = self.contentView else { return CGRect.zero }
        return self.convert(contentView.frame, from: contentView.superview)
    }
    
    @objc open override var finalViewportRect: CGRect {
        let rect = super.finalViewportRect
        if let deleagte = self.delegate, deleagte.responds(to: #selector(ZoomImageViewDelegate.zoomImageView(_:finalViewportRect:))) {
            return deleagte.zoomImageView!(self, finalViewportRect: rect)
        }
        return rect
    }
    
    @objc open var isDisplayImageView: Bool {
        return isImageViewInitialized && !self.imageView.isHidden
    }
    
    @objc open var isDisplayLivePhotoView: Bool {
        return isLivePhotoViewInitialized && !self.livePhotoView.isHidden
    }
    
    @objc var isAnimating: Bool {
        if self.isDisplayImageView {
            return self.imageView.isAnimating
        } else if self.isDisplayLivePhotoView {
            return self.isLivePhotoPlaying
        }
        return false
    }
    
    @objc open func startAnimating() -> Void {
        if self.isDisplayImageView {
            self.imageView.startAnimating()
        } else if self.isDisplayLivePhotoView {
            self.livePhotoView.startPlayback(with: .full)
        }
    }
    
    @objc open func stopAnimating() -> Void {
        if self.isDisplayImageView {
            self.imageView.stopAnimating()
        } else if self.isDisplayLivePhotoView {
            self.livePhotoView.stopPlayback()
        }
    }
    
    @objc open var finalEnabledZoom: Bool {
        var enabledZoom: Bool = self.enabledZoom
        if self.contentView == nil {
            enabledZoom = false
        }
        return enabledZoom
    }
    
    @objc open var finalMinimumZoomScale: CGFloat {
        if self.contentView == nil || (self.image == nil && self.livePhoto == nil) {
            return 1
        }
        let viewport: CGRect = self.finalViewportRect
        var mediaSize: CGSize = CGSize.zero
        if let image = self.image {
            mediaSize = image.size
        } else if let livePhoto = self.livePhoto {
            mediaSize = livePhoto.size
        }
        var contentMode = self.contentMode
        var minScale: CGFloat = 1
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
                minScale = 1
            } else {
                minScale = min(scaleX, scaleY)
            }
        }
        return minScale
    }
    
    @objc open func revertZooming() -> Void {
        if self.bounds.isEmpty {
            return
        }
        let finalEnabledZoom: Bool = self.finalEnabledZoom
        let minimumZoomScale: CGFloat = self.finalMinimumZoomScale
        let maximumZoomScale: CGFloat = max(finalEnabledZoom ? self.maximumZoomScale : minimumZoomScale, minimumZoomScale)
        let zoomScale: CGFloat = minimumZoomScale
        let shouldFireDidZoomingManual: Bool = zoomScale == self.zoomScale
        self.scrollView?.panGestureRecognizer.isEnabled = finalEnabledZoom
        self.scrollView?.pinchGestureRecognizer?.isEnabled = finalEnabledZoom
        self.scrollView?.minimumZoomScale = minimumZoomScale
        self.scrollView?.maximumZoomScale = maximumZoomScale
        /// 重置Frame
        if let contentView = self.contentView {
            contentView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        }
        /// 重置ZoomScale
        self.setZoom(scale: zoomScale, animated: false)
        /// 手动触发一次缩放
        if shouldFireDidZoomingManual {
            self.handleDidEndZooming()
        }
        /// 重置ContentOffset
        self.revertContentOffset(animated: false)
    }
    
    @objc open func revertContentOffset(animated: Bool = true) -> Void {
        if let scrollView = self.scrollView {
            var x: CGFloat = scrollView.contentOffset.x
            var y: CGFloat = scrollView.contentOffset.y
            let viewport: CGRect = self.finalViewportRect
            if let contentView = self.contentView, !viewport.isEmpty {
                if viewport.width < contentView.frame.width {
                    x = (contentView.frame.width - viewport.width) / 2 - viewport.minX
                }
                if viewport.height < contentView.frame.height {
                    y = -scrollView.contentInset.top
                }
            }
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
        }
    }
    
    @objc open var zoomScale: CGFloat {
        return self.scrollView?.zoomScale ?? 1
    }
    
    @objc open func setZoom(scale: CGFloat, animated: Bool = true) -> Void {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: AnimationOptionsCurveOut, animations: {
                self.scrollView?.zoomScale = scale
            }, completion: nil)
        } else {
            self.scrollView?.zoomScale = scale
        }
    }
    
    @objc(zoomToPoint:animated:)
    open func zoom(to point: CGPoint, animated: Bool = true) -> Void {
        guard let scrollView = self.scrollView else { return }
        guard let cententView = self.contentView else { return }
        var newZoomScale: CGFloat = 0
        if self.zoomScale < 1 {
            /// 如果目前显示的大小比原图小，则放大到原图
            newZoomScale = 1
        } else {
            /// 如果当前显示原图，则放大到最大的大小
            newZoomScale = self.maximumZoomScale
        }
        let tapPoint: CGPoint = cententView.convert(point, from: scrollView)
        var zoomRect: CGRect = CGRect.zero
        zoomRect.size.width = scrollView.bounds.width / newZoomScale
        zoomRect.size.height = scrollView.bounds.height / newZoomScale
        zoomRect.origin.x = tapPoint.x - zoomRect.width / 2
        zoomRect.origin.y = tapPoint.y - zoomRect.height / 2
        self.zoom(to: zoomRect, animated: animated)
    }
    
    @objc(zoomToRect:animated:)
    open func zoom(to rect: CGRect, animated: Bool = true) -> Void {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: AnimationOptionsCurveOut, animations: {
                self.scrollView?.zoom(to: rect, animated: false)
            }, completion: nil)
        } else {
            self.scrollView?.zoom(to: rect, animated: false)
        }
    }
    
    private func handleDidEndZooming() -> Void {
        guard let contentView = self.contentView else { return }
        guard let scrollView = self.scrollView else { return }
        /// 不需要setNeedsLayout, 当没有标记时, 说明已经布局完毕, 当存在标记时才立刻调用layoutSubviews
        self.layoutIfNeeded()
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
        scrollView.contentInset = contentInset
        scrollView.contentSize = contentView.frame.size
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
