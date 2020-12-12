//
//  ZoomBaseView.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/11.
//

import UIKit

public class ZoomBaseView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    public func didInitialize(frame: CGRect) -> Void {
        
    }
    
}

extension ZoomBaseView {
    
    @objc public var containerView: UIView? {
        get {
            return nil
        }
    }
    
    @objc public var contentView: UIView? {
        get {
            return nil
        }
    }
    
    @objc open func contentViewRectInZoomView() -> CGRect {
        guard let contentView = self.contentView else {
            return CGRect.zero
        }
        return self.convert(contentView.frame, from: contentView.superview)
    }
    
}
