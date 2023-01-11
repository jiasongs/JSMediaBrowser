//
//  BasisMediaView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import JSCoreKit

public class BasisMediaView: UIView {
    
    public var isEnableVerticalSafeArea = JSCoreHelper.isMac ? true : false
    
    public var viewportRect: CGRect = .zero
    /// 以下属性viewportRect为zero时才会生效, 若自定义viewportRect, 请自行实现
    public var viewportRectMaxWidth: CGFloat = 580
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    public func didInitialize() {
        
    }
    
    public var containerView: UIView {
        return self
    }
    
    public var contentView: UIView? {
        return nil
    }
    
    public var contentViewFrame: CGRect {
        return CGRect.zero
    }
    
    var finalViewportRect: CGRect {
        var safeAreaInsets: UIEdgeInsets = self.safeAreaInsets
        if !self.isEnableVerticalSafeArea {
            /// 关闭垂直的安全区域
            safeAreaInsets.top = 0
            safeAreaInsets.bottom = 0
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
