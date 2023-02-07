//
//  SliderView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/4.
//

import UIKit

public class SliderView: UISlider {
    
    public var trackHeight: CGFloat = 0
    
    public var thumbSize: CGSize = CGSize.zero {
        didSet {
            self.updateThumbImage()
        }
    }
    
    public var thumbColor: UIColor? {
        didSet {
            self.updateThumbImage()
        }
    }
    
    public var thumbShadowColor: UIColor? {
        didSet {
            if let thumbView = self.thumbViewIfExist {
                thumbView.layer.shadowColor = thumbShadowColor?.cgColor
                thumbView.layer.shadowOpacity = thumbShadowColor != nil ? 1 : 0
            }
        }
    }
    
    public var thumbShadowOffset: CGSize = CGSize.zero {
        didSet {
            if let thumbView = self.thumbViewIfExist {
                thumbView.layer.shadowOffset = thumbShadowOffset
            }
        }
    }
    
    public var thumbShadowRadius: CGFloat = 0 {
        didSet {
            if let thumbView = self.thumbViewIfExist {
                thumbView.layer.shadowRadius = thumbShadowRadius
            }
        }
    }
    
}

extension SliderView {
    
    public override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        if self.trackHeight > 0 {
            rect.size.height = self.trackHeight
            rect.origin.y = (bounds.height - rect.height) / 2.0
            return rect
        }
        return rect
    }
    
    public override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if let thumbView: UIView = self.thumbViewIfExist, thumbView == subview {
            thumbView.layer.shadowColor = self.thumbShadowColor?.cgColor
            thumbView.layer.shadowOpacity = self.thumbShadowColor != nil ? 1 : 0
            thumbView.layer.shadowOffset = self.thumbShadowOffset
            thumbView.layer.shadowRadius = self.thumbShadowRadius
        }
    }
    
}

extension SliderView {
    
    fileprivate var thumbViewIfExist: UIView? {
        return self.value(forKey: "thumbView") as? UIView
    }
    
    fileprivate func updateThumbImage() {
        let thumbColor = self.thumbColor != nil ? self.thumbColor! : self.tintColor
        UIGraphicsBeginImageContextWithOptions(self.thumbSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            let path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: self.thumbSize))
            context.setFillColor(thumbColor?.cgColor ?? UIColor.white.cgColor)
            path.fill()
            let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
            self.setThumbImage(thumbImage, for: .normal)
            self.setThumbImage(thumbImage, for: .highlighted)
        }
        UIGraphicsEndImageContext()
    }
    
}
