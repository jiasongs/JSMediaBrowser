//
//  BasisMediaView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit

open class BasisMediaView: UIView {
    
    public var isEnableVerticalSafeArea = false
    public var viewportRect: CGRect = .zero
    /// 以下属性viewportRect为zero时才会生效, 若自定义viewportRect, 请自行实现
    public var viewportRectMaxWidth: CGFloat = 700
    
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
    
    open var containerView: UIView {
        return self
    }
    
    open var contentView: UIView? {
        return nil
    }
    
    open var contentViewFrame: CGRect {
        return CGRect.zero
    }
    
    open var finalViewportRect: CGRect {
        if self.containerView.bounds.size != self.bounds.size {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        var safeAreaInsets: UIEdgeInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            safeAreaInsets = self.safeAreaInsets
            if !self.isEnableVerticalSafeArea {
                /// 关闭垂直的安全区域
                safeAreaInsets.top = 0
                safeAreaInsets.bottom = 0
            }
        }
        var rect: CGRect = self.viewportRect
        if rect.isEmpty && !self.bounds.isEmpty {
            let size: CGSize = CGSize(width: min(self.containerView.bounds.width, self.viewportRectMaxWidth),
                                      height: self.containerView.bounds.height)
            let offsetX = (self.containerView.bounds.width - size.width) / 2
            let top = safeAreaInsets.top
            let left = max(safeAreaInsets.left, offsetX)
            let bottom = safeAreaInsets.bottom
            let right = safeAreaInsets.right
            rect = CGRect(x: left,
                          y: top,
                          width: min(size.width, self.containerView.bounds.width - left - right),
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
