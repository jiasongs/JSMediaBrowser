//
//  ZoomImageView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import PhotosUI
import JSCoreKit

open class ZoomImageView: ZoomBaseView {
    
    @objc private(set) var scrollView: UIScrollView?
    
    private var isImageViewInitialized: Bool = false
    @objc private(set) lazy var imageView: UIImageView = {
        isImageViewInitialized = true
        let imageView = UIImageView()
        imageView.isHidden = true
        scrollView?.addSubview(imageView)
        return imageView
    }()
    
    private var isLivePhotoViewInitialized: Bool = false
    @objc private(set) lazy var livePhotoView: PHLivePhotoView = {
        isLivePhotoViewInitialized = true
        let livePhotoView = PHLivePhotoView()
        livePhotoView.isHidden = true
        scrollView?.addSubview(livePhotoView)
        return livePhotoView
    }()
    
    @objc public var viewportRect: CGRect = CGRect.zero
    @objc public var viewportRectMaxWidth: CGFloat = 700
    
    @objc public var maximumZoomScale: CGFloat = 2.0 {
        didSet {
            scrollView?.maximumZoomScale = maximumZoomScale
        }
    }
    
    @objc public weak var image: UIImage? {
        didSet {
            if image == nil && !isImageViewInitialized {
                return
            }
            if isLivePhotoViewInitialized {
                livePhotoView.isHidden = true
                livePhotoView.livePhoto = nil
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
                imageView.isHidden = true
                imageView.image = nil
            }
            self.livePhotoView.isHidden = false
            self.livePhotoView.livePhoto = livePhoto
            self.livePhotoView.js_frameApplyTransform = CGRect(origin: CGPoint.zero, size: livePhoto?.size ?? CGSize.zero)
            self.revertZooming()
        }
    }
    
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
    
    @objc open override var containerView: UIView? {
        get {
            return self.scrollView
        }
    }
    
    @objc open override var contentView: UIView? {
        get {
            if (isImageViewInitialized && !imageView.isHidden) {
                return imageView
            }
            if (isLivePhotoViewInitialized && !livePhotoView.isHidden) {
                return livePhotoView
            }
            return nil
        }
    }
    
    @objc open override var contentViewRectInZoomView: CGRect {
        return super.contentViewRectInZoomView
    }
    
    @objc open var finalViewportRect: CGRect {
        var rect: CGRect = self.viewportRect
        if (rect.isEmpty && !self.bounds.isEmpty) {
            if let scrollView = self.scrollView {
                if !scrollView.bounds.size.equalTo(self.bounds.size) {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
                let safeAreaInsets: UIEdgeInsets = JSCoreHelper.safeAreaInsetsForDeviceWithNotch()
                let size: CGSize = CGSize(width: min(scrollView.bounds.width, viewportRectMaxWidth), height: scrollView.bounds.height)
                let offsetX = (scrollView.bounds.width - size.width) / 2
                let top = safeAreaInsets.top
                let left = max(safeAreaInsets.left, offsetX)
                let bottom = safeAreaInsets.bottom
                let right = safeAreaInsets.right
                rect = CGRect(x: left, y: top, width: min(size.width, scrollView.bounds.width - left - right), height: size.height - top - bottom)
            }
        }
        return rect
    }
    
    @objc open var finalEnabledZoom: Bool {
        var enabledZoom: Bool = self.enabledZoom
        if self.contentView == nil {
            enabledZoom = false
        }
        return enabledZoom
    }
    
    @objc open var finalMinimumZoomScale: CGFloat {
        get {
            if self.image == nil && self.livePhoto == nil {
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
            if let image = self.image {
                let radio: CGFloat = image.size.height / image.size.width
                let finalHeight: CGFloat = image.size.width > viewport.width ? viewport.width * radio : image.size.height
                if (finalHeight > viewport.height) {
                    contentMode = .scaleAspectFill
                }
            }
            if (contentMode == .scaleAspectFit) {
                minScale = min(scaleX, scaleY)
            } else if (contentMode == .scaleAspectFill) {
                minScale = max(scaleX, scaleY)
            } else if (contentMode == .center) {
                if (scaleX >= 1 && scaleY >= 1) {
                    minScale = 1
                } else {
                    minScale = min(scaleX, scaleY)
                }
            }
            return minScale
        }
    }
    
    @objc open func revertZooming() -> Void {
        if (self.bounds.isEmpty) {
            return
        }
        let finalEnabledZoom: Bool = self.finalEnabledZoom
        let minimumZoomScale: CGFloat = self.finalMinimumZoomScale
        let maximumZoomScale: CGFloat = max(finalEnabledZoom ? self.maximumZoomScale : minimumZoomScale, minimumZoomScale)
        let zoomScale: CGFloat = minimumZoomScale
        let shouldFireDidZoomingManual: Bool = zoomScale == self.scrollView?.zoomScale
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
        if (shouldFireDidZoomingManual) {
            self.handleDidEndZooming()
        }
        /// 重置ContentOffset
        self.revertContentOffset(animated: false)
    }
    
    @objc open func revertContentOffset(animated: Bool) -> Void {
        if let scrollView = self.scrollView {
            var x: CGFloat = scrollView.contentOffset.x
            var y: CGFloat = scrollView.contentOffset.y
            let viewport: CGRect = self.finalViewportRect
            if let contentView = self.contentView, !viewport.isEmpty {
                if (viewport.width < contentView.frame.width) {
                    x = (contentView.frame.width - viewport.width) / 2 - viewport.minX
                }
                if (viewport.height < contentView.frame.height) {
                    y = -scrollView.contentInset.top
                }
            }
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
        }
    }
    
    @objc open func setZoom(scale: CGFloat, animated: Bool) -> Void {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: AnimationOptionsCurveOut, animations: {
                self.scrollView?.zoomScale = scale
            }, completion: nil)
        } else {
            self.scrollView?.zoomScale = scale
        }
    }
    
    @objc open func zoom(to rect: CGRect, animated: Bool) -> Void {
        if (animated) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: AnimationOptionsCurveOut, animations: {
                self.scrollView?.zoom(to: rect, animated: false)
            }, completion: nil)
        } else {
            self.scrollView?.zoom(to: rect, animated: false)
        }
    }
    
    @objc open func zoom(to point: CGPoint, from view: UIView?, animated: Bool) -> Void {
        guard let scrollView = self.scrollView else { return }
        guard let cententView = self.contentView else { return }
        // 如果图片被压缩了，则第一次放大到原图大小，第二次放大到最大倍数
        if (scrollView.zoomScale >= scrollView.maximumZoomScale) {
            self.setZoom(scale: scrollView.minimumZoomScale, animated: animated)
        } else {
            var newZoomScale: CGFloat = 0
            if (scrollView.zoomScale < 1) {
                // 如果目前显示的大小比原图小，则放大到原图
                newZoomScale = 1
            } else {
                // 如果当前显示原图，则放大到最大的大小
                newZoomScale = scrollView.maximumZoomScale
            }
            let tapPoint: CGPoint = cententView.convert(point, from: view)
            var zoomRect: CGRect = CGRect.zero
            zoomRect.size.width = scrollView.bounds.width / newZoomScale
            zoomRect.size.height = scrollView.bounds.height / newZoomScale
            zoomRect.origin.x = tapPoint.x - zoomRect.width / 2
            zoomRect.origin.y = tapPoint.y - zoomRect.height / 2
            self.zoom(to: zoomRect, animated: animated)
        }
    }
    
}

extension ZoomImageView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if (self.bounds.isEmpty) {
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
    
    private func handleDidEndZooming() -> Void {
        guard let contentView = self.contentView else { return }
        guard let scrollView = self.scrollView else { return }
        let viewport: CGRect = self.finalViewportRect
        // 强制 layout 以确保下面的一堆计算依赖的都是最新的 frame 的值
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let contentViewFrame: CGRect = self.contentViewRectInZoomView
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
