//
//  BasisMediaView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit

@objc(JSMediaBrowserBasisMediaView)
open class BasisMediaView: UIView {
    
    @objc public var viewportRect: CGRect = .zero
    /// 当viewportRect为zero时才会生效, 若自定义viewportRect, 请自行实现
    @objc public var viewportRectMaxWidth: CGFloat = 700
    @objc public var viewportSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    open func didInitialize(frame: CGRect) {
    }
    
}

extension BasisMediaView {
    
    @objc open var containerView: UIView? {
        return nil
    }
    
    @objc open var contentView: UIView? {
        return nil
    }
    
    @objc open var contentViewFrame: CGRect {
        return CGRect.zero
    }
    
    @objc open var finalViewportRect: CGRect {
        var rect: CGRect = self.viewportRect
        guard let containerView = self.containerView else { return rect }
        if !containerView.bounds.size.equalTo(self.bounds.size) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        let safeAreaInsets: UIEdgeInsets = self.viewportSafeAreaInsets
        if rect.isEmpty && !self.bounds.isEmpty {
            let size: CGSize = CGSize(width: min(containerView.bounds.width, self.viewportRectMaxWidth), height: containerView.bounds.height)
            let offsetX = (containerView.bounds.width - size.width) / 2
            let top = safeAreaInsets.top
            let left = max(safeAreaInsets.left, offsetX)
            let bottom = safeAreaInsets.bottom
            let right = safeAreaInsets.right
            rect = CGRect(x: left,
                          y: top,
                          width: min(size.width, containerView.bounds.width - left - right),
                          height: size.height - top - bottom)
        } else {
            rect = CGRect(x: rect.minX + safeAreaInsets.left,
                          y: rect.minY - safeAreaInsets.top,
                          width: rect.width - (safeAreaInsets.left + safeAreaInsets.right),
                          height: rect.height - (safeAreaInsets.top + safeAreaInsets.bottom))
        }
        return rect
    }
    
}
