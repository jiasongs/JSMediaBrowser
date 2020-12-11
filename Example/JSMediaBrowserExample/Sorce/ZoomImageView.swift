//
//  ZoomImageView.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import PhotosUI
import QMUIKit

public class ZoomImageView: ZoomBaseView {
    
    private(set) var scrollView: UIScrollView!
    
    private var isImageViewInitialized: Bool = false
    private(set) lazy var imageView: UIImageView = {
        isImageViewInitialized = true
        let imageView = UIImageView.init()
        imageView.isHidden = true
        self.scrollView.addSubview(imageView)
        return imageView
    }()
    
    private var isLivePhotoViewViewInitialized: Bool = false
    private(set) lazy var livePhotoView: PHLivePhotoView = {
        isLivePhotoViewViewInitialized = true
        let livePhotoView = PHLivePhotoView.init()
        livePhotoView.isHidden = true
        self.scrollView.addSubview(livePhotoView)
        return livePhotoView
    }()
    
    public var contentView: UIView? {
        get {
            if (isImageViewInitialized && !imageView.isHidden) {
                return imageView
            }
            if (isLivePhotoViewViewInitialized && !livePhotoView.isHidden) {
                return livePhotoView
            }
            return nil
        }
    }
    
    public var viewportRect: CGRect = CGRect.zero
    
    public var maximumZoomScale: CGFloat = 2.0 {
        didSet {
            self.scrollView.maximumZoomScale = maximumZoomScale
        }
    }
    
    public weak var image: UIImage? {
        didSet {
            self.livePhotoView.isHidden = true
            self.imageView.isHidden = false
            if self.image != nil {
                self.imageView.image = self.image
                self.imageView.qmui_frameApplyTransform = CGRect.init(origin: CGPoint.zero, size: self.image?.size ?? CGSize.zero)
                self.revertZooming()
            }
        }
    }
    
    public weak var livePhoto: PHLivePhoto? {
        didSet {
            self.livePhotoView.isHidden = false
            self.imageView.isHidden = true
            if self.livePhoto != nil {
                self.livePhotoView.livePhoto = self.livePhoto
                self.livePhotoView.qmui_frameApplyTransform = CGRect.init(origin: CGPoint.zero, size: self.image?.size ?? CGSize.zero)
                self.revertZooming()
            }
        }
    }
    
    public var minimumZoomScale: CGFloat {
        get {
            if self.image == nil && self.livePhoto == nil {
                return 1
            }
            let viewport: CGRect = self.finalViewportRect()
            var mediaSize: CGSize = CGSize.zero
            if self.image != nil {
                mediaSize = self.image!.size
            } else if self.livePhoto != nil {
                mediaSize = self.livePhoto!.size
            }
            var minScale: CGFloat = 1
            let scaleX: CGFloat = viewport.width / mediaSize.width
            let scaleY: CGFloat = viewport.height / mediaSize.height
            if (self.contentMode == .scaleAspectFit) {
                minScale = min(scaleX, scaleY)
            } else if (self.contentMode == .scaleAspectFill) {
                minScale = max(scaleX, scaleY)
            } else if (self.contentMode == .center) {
                if (scaleX >= 1 && scaleY >= 1) {
                    minScale = 1
                } else {
                    minScale = min(scaleX, scaleY)
                }
            }
            return minScale
        }
    }
    
    public var enabledZoom: Bool = true
        
    public override func didInitialize(frame: CGRect) -> Void {
        super.didInitialize(frame: frame);
        self.contentMode = .center
        
        self.scrollView = UIScrollView.init(frame: CGRect.init(origin: CGPoint.zero, size: frame.size))
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.minimumZoomScale = 0
        self.scrollView.maximumZoomScale = self.maximumZoomScale
        self.scrollView.delegate = self
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        self.addSubview(self.scrollView)
    }
    
}

extension ZoomImageView {
    
    @objc open func contentViewRectInZoomImageView() -> CGRect {
        if (self.contentView == nil) {
            return CGRect.zero
        }
        return self.convert(self.contentView!.frame, from: self.contentView!.superview)
    }
    
    @objc open func revertZooming() -> Void {
        if (self.bounds.isEmpty) {
            return
        }
        let enabledZoomImageView: Bool = self.enabledZoomImageView()
        let minimumZoomScale: CGFloat = self.maximumZoomScale
        var maximumZoomScale: CGFloat = enabledZoomImageView ? self.maximumZoomScale : minimumZoomScale
        maximumZoomScale = max(minimumZoomScale, maximumZoomScale)
        let zoomScale: CGFloat = minimumZoomScale
        let shouldFireDidZoomingManual: Bool = zoomScale == self.scrollView.zoomScale
        self.scrollView.panGestureRecognizer.isEnabled = enabledZoomImageView
        self.scrollView.pinchGestureRecognizer?.isEnabled = enabledZoomImageView
        self.scrollView.minimumZoomScale = minimumZoomScale
        self.scrollView.maximumZoomScale = maximumZoomScale
        self.contentView?.frame = CGRectSetXY(self.contentView?.frame ?? CGRect.zero, 0, 0)
        self.setZoom(scale: zoomScale, animated: false)
        if (shouldFireDidZoomingManual) {
            self.handleDidEndZooming()
        }
        self.scrollView.contentOffset = { () -> CGPoint in
            var x: CGFloat = self.scrollView.contentOffset.x
            var y: CGFloat = self.scrollView.contentOffset.y
            let viewport: CGRect = self.finalViewportRect()
            if (!viewport.isEmpty && self.contentView != nil) {
                let contentView: UIView = self.contentView!
                if (viewport.width < contentView.frame.width) {
                    x = contentView.frame.width / 2 - viewport.width / 2 - viewport.minX
                }
                if (viewport.height < contentView.frame.height) {
                    y = 0
                }
            }
            return CGPoint.init(x: x, y: y)
        }()
    }
    
    @objc open func finalViewportRect() -> CGRect {
        var rect: CGRect = self.viewportRect
        if (rect.isEmpty && !self.bounds.isEmpty) {
            // 有可能此时还没有走到过 layoutSubviews 因此拿不到正确的 scrollView 的 size，因此这里要强制 layout 一下
            if (!self.scrollView.bounds.size.equalTo(self.bounds.size)) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            rect = CGRectMakeWithSize(self.scrollView.bounds.size)
        }
        return rect
    }
    
    @objc open func setZoom(scale: CGFloat, animated: Bool) -> Void {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(QMUIViewAnimationOptionsCurveOut)), animations: {
                self.scrollView.zoomScale = scale
            }, completion: nil)
        } else {
            self.scrollView.zoomScale = scale
        }
    }
    
    @objc open func zoom(to rect: CGRect, animated: Bool) -> Void {
        if (animated) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(QMUIViewAnimationOptionsCurveOut)), animations: {
                self.scrollView.zoom(to: rect, animated: animated)
            }, completion: nil)
        } else {
            self.scrollView.zoom(to: rect, animated: animated)
        }
    }
    
}

extension ZoomImageView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if (self.bounds.isEmpty) {
            return
        }
        self.scrollView.frame = self.bounds
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
    
    private func enabledZoomImageView() -> Bool {
        var enabledZoom: Bool = self.enabledZoom
        if ((isImageViewInitialized && isLivePhotoViewViewInitialized) || imageView.isHidden && livePhotoView.isHidden) {
            enabledZoom = false
        }
        return enabledZoom
    }
    
    private func handleDidEndZooming() -> Void {
        if self.contentView == nil {
            return
        }
        let contentView: UIView = self.contentView!
        let viewport: CGRect = self.finalViewportRect()
        // 强制 layout 以确保下面的一堆计算依赖的都是最新的 frame 的值
        self.layoutIfNeeded()
        let contentViewFrame: CGRect = self.convert(contentView.frame, from: contentView.superview)
        var contentInset: UIEdgeInsets = UIEdgeInsets.zero
        contentInset.top = viewport.minY
        contentInset.left = viewport.minX
        contentInset.right = self.bounds.width - viewport.maxX
        contentInset.bottom = self.bounds.height - viewport.maxY
        if (viewport.height > contentViewFrame.height) {
            contentInset.top = floor(viewport.midY - contentViewFrame.height / 2.0)
            contentInset.bottom = floor(self.bounds.height - viewport.midY - contentViewFrame.height / 2.0)
        }
        if (viewport.width > contentViewFrame.width) {
            contentInset.left = floor(viewport.midX - contentViewFrame.width / 2.0)
            contentInset.right = floor(self.bounds.width - viewport.midY - contentViewFrame.width / 2.0)
        }
        self.scrollView.contentInset = contentInset
        self.scrollView.contentSize = contentView.frame.size
    }
    
    @objc public override func handleDoubleTapGestureWithPoint(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        if (self.enabledZoomImageView()) {
            let gesturePoint: CGPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            // 如果图片被压缩了，则第一次放大到原图大小，第二次放大到最大倍数
            if (self.scrollView.zoomScale >= self.scrollView.maximumZoomScale) {
                self.setZoom(scale: self.scrollView.minimumZoomScale, animated: true)
            } else {
                var newZoomScale: CGFloat = 0
                if (self.scrollView.zoomScale < 1) {
                    // 如果目前显示的大小比原图小，则放大到原图
                    newZoomScale = 1
                } else {
                    // 如果当前显示原图，则放大到最大的大小
                    newZoomScale = self.scrollView.maximumZoomScale
                }
                var zoomRect: CGRect = CGRect.zero
                let tapPoint: CGPoint = self.contentView?.convert(gesturePoint, from: gestureRecognizer.view) ?? CGPoint.zero
                zoomRect.size.width = self.bounds.width / newZoomScale
                zoomRect.size.height = self.bounds.height / newZoomScale
                zoomRect.origin.x = tapPoint.x - zoomRect.width / 2
                zoomRect.origin.y = tapPoint.y - zoomRect.height / 2
                self.zoom(to: zoomRect, animated: true)
            }
        }
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
