//
//  ZoomImageView.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import PhotosUI
import JSCoreKit

public class ZoomImageView: ZoomBaseView {
    
    @objc private(set) var scrollView: UIScrollView?
    
    private var isImageViewInitialized: Bool = false
    @objc private(set) lazy var imageView: UIImageView = {
        isImageViewInitialized = true
        let imageView = UIImageView.init()
        imageView.isHidden = true
        self.scrollView?.addSubview(imageView)
        return imageView
    }()
    
    private var isLivePhotoViewViewInitialized: Bool = false
    @objc private(set) lazy var livePhotoView: PHLivePhotoView = {
        isLivePhotoViewViewInitialized = true
        let livePhotoView = PHLivePhotoView.init()
        livePhotoView.isHidden = true
        self.scrollView?.addSubview(livePhotoView)
        return livePhotoView
    }()
    
    @objc public var viewportRect: CGRect = CGRect.zero
    @objc public var viewportRectMaxWidth: CGFloat = 700;
    
    @objc public var maximumZoomScale: CGFloat = 2.0 {
        didSet {
            self.scrollView?.maximumZoomScale = maximumZoomScale
        }
    }
    
    @objc public weak var image: UIImage? {
        didSet {
            if isLivePhotoViewViewInitialized {
                self.livePhotoView.isHidden = true
            }
            self.imageView.isHidden = false
            if self.image != nil {
                self.imageView.image = self.image
                self.imageView.js_frameApplyTransform = CGRect.init(origin: CGPoint.zero, size: self.image?.size ?? CGSize.zero)
                
                self.revertZooming()
            }
        }
    }
    
    @objc public weak var livePhoto: PHLivePhoto? {
        didSet {
            if isImageViewInitialized {
                self.imageView.isHidden = true
            }
            self.livePhotoView.isHidden = false
            if self.livePhoto != nil {
                self.livePhotoView.livePhoto = self.livePhoto
                self.livePhotoView.js_frameApplyTransform = CGRect.init(origin: CGPoint.zero, size: self.image?.size ?? CGSize.zero)
                self.revertZooming()
            }
        }
    }
    
    @objc public var enabledZoom: Bool = true
    
    public override func didInitialize(frame: CGRect) -> Void {
        super.didInitialize(frame: frame);
        self.contentMode = .center
        
        self.scrollView = UIScrollView.init(frame: CGRect.init(origin: CGPoint.zero, size: frame.size))
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.minimumZoomScale = 0
        self.scrollView?.maximumZoomScale = self.maximumZoomScale
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
            if (isLivePhotoViewViewInitialized && !livePhotoView.isHidden) {
                return livePhotoView
            }
            return nil
        }
    }
    
    @objc open override func contentViewRectInZoomView() -> CGRect {
        return super.contentViewRectInZoomView()
    }
    
    @objc open func revertZooming() -> Void {
        if (self.bounds.isEmpty) {
            return
        }
        let enabledZoomImageView: Bool = self.enabledZoomImageView
        let minimumZoomScale: CGFloat = self.minimumZoomScale
        var maximumZoomScale: CGFloat = enabledZoomImageView ? self.maximumZoomScale : minimumZoomScale
        maximumZoomScale = max(minimumZoomScale, maximumZoomScale)
        let zoomScale: CGFloat = minimumZoomScale
        let shouldFireDidZoomingManual: Bool = zoomScale == self.scrollView?.zoomScale
        self.scrollView?.panGestureRecognizer.isEnabled = enabledZoomImageView
        self.scrollView?.pinchGestureRecognizer?.isEnabled = enabledZoomImageView
        self.scrollView?.minimumZoomScale = minimumZoomScale
        self.scrollView?.maximumZoomScale = maximumZoomScale
        /// 重置Frame
        if let contentView = self.contentView {
            contentView.frame = CGRect.init(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        }
        self.setZoom(scale: zoomScale, animated: false)
        if (shouldFireDidZoomingManual) {
            self.handleDidEndZooming()
        }
        self.scrollView?.contentOffset = { () -> CGPoint in
            var x: CGFloat = self.scrollView?.contentOffset.x ?? 0
            var y: CGFloat = self.scrollView?.contentOffset.y ?? 0
            let viewport: CGRect = self.finalViewportRect()
            if let contentView = self.contentView, !viewport.isEmpty {
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
            let size: CGSize = CGSize.init(width: min(self.bounds.width, viewportRectMaxWidth), height: self.bounds.height)
            rect = CGRect.init(x: (self.bounds.width - size.width) / 2, y: 0, width: size.width, height: size.height)
        }
        return rect
    }
    
    @objc open func setZoom(scale: CGFloat, animated: Bool) -> Void {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.scrollView?.zoomScale = scale
            }, completion: nil)
        } else {
            self.scrollView?.zoomScale = scale
        }
    }
    
    @objc open func zoom(to rect: CGRect, animated: Bool) -> Void {
        if (animated) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.scrollView?.zoom(to: rect, animated: animated)
            }, completion: nil)
        } else {
            self.scrollView?.zoom(to: rect, animated: animated)
        }
    }
    
    @objc open func zoom(from gestureRecognizer: UIGestureRecognizer, animated: Bool) -> Void {
        guard let scrollView = self.scrollView else { return }
        guard let cententView = self.contentView else { return }
        let gesturePoint: CGPoint = gestureRecognizer.location(in: gestureRecognizer.view)
        // 如果图片被压缩了，则第一次放大到原图大小，第二次放大到最大倍数
        if (scrollView.zoomScale >= scrollView.maximumZoomScale) {
            self.setZoom(scale: scrollView.minimumZoomScale, animated: true)
        } else {
            var newZoomScale: CGFloat = 0
            if (scrollView.zoomScale < 1) {
                // 如果目前显示的大小比原图小，则放大到原图
                newZoomScale = 1
            } else {
                // 如果当前显示原图，则放大到最大的大小
                newZoomScale = scrollView.maximumZoomScale
            }
            let tapPoint: CGPoint = cententView.convert(gesturePoint, from: gestureRecognizer.view)
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
    
    private var enabledZoomImageView: Bool {
        var enabledZoom: Bool = self.enabledZoom
        if self.contentView == nil {
            enabledZoom = false;
        }
        return enabledZoom
    }
    
    private var minimumZoomScale: CGFloat {
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
            var contentMode = self.contentMode
            var minScale: CGFloat = 1
            let scaleX: CGFloat = viewport.width / mediaSize.width
            let scaleY: CGFloat = viewport.height / mediaSize.height
            if let image = self.image {
                let radio: CGFloat = image.size.height / image.size.width
                let finalHeight: CGFloat = image.size.width > viewport.width ? viewport.width * radio : image.size.height;
                if (finalHeight > viewport.height) {
                    contentMode = .scaleAspectFill;
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
    
    private func handleDidEndZooming() -> Void {
        guard let contentView = self.contentView else { return }
        let viewport: CGRect = self.finalViewportRect()
        // 强制 layout 以确保下面的一堆计算依赖的都是最新的 frame 的值
        self.layoutIfNeeded()
        let contentViewFrame: CGRect = self.contentViewRectInZoomView()
        var contentInset: UIEdgeInsets = UIEdgeInsets.zero
        contentInset.top = viewport.minY
        contentInset.left = viewport.minX
        contentInset.right = self.bounds.width - viewport.maxX
        contentInset.bottom = self.bounds.height - viewport.maxY
        if viewport.height >= contentViewFrame.height {
            contentInset.top = floor(viewport.midY - contentViewFrame.height / 2.0)
            contentInset.bottom = floor(self.bounds.height - viewport.midY - contentViewFrame.height / 2.0)
        }
        if viewport.width >= contentViewFrame.width {
            contentInset.left = floor(viewport.midX - contentViewFrame.width / 2.0)
            contentInset.right = floor(self.bounds.width - viewport.midX - contentViewFrame.width / 2.0)
        }
        self.scrollView?.contentInset = contentInset
        self.scrollView?.contentSize = contentView.frame.size
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
