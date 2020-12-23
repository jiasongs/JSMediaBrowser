//
//  ZoomBaseView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/11.
//

import UIKit

open class ZoomBaseView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    func didInitialize(frame: CGRect) -> Void {
        
    }
    
}

extension ZoomBaseView {
    
    @objc open var containerView: UIView? {
        get {
            return nil
        }
    }
    
    @objc open var contentView: UIView? {
        get {
            return nil
        }
    }
    
    @objc open var contentViewRectInZoomView: CGRect {
        guard let contentView = self.contentView else {
            return CGRect.zero
        }
        return self.convert(contentView.frame, from: contentView.superview)
    }
    
}
