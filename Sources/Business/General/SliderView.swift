//
//  SliderView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/4.
//

import UIKit

open class SliderView: UISlider {
    
    open var trackHeight: CGFloat = 0
    open var thumbSize: CGSize = CGSize.zero {
        didSet {
            self.updateThumbImage()
        }
    }
    open var thumbColor: UIColor? {
        didSet {
            self.updateThumbImage()
        }
    }
    open var thumbShadowColor: UIColor? {
        didSet {
            if let thumbView = self.thumbViewIfExist {
                thumbView.layer.shadowColor = thumbShadowColor?.cgColor
                thumbView.layer.shadowOpacity = thumbShadowColor != nil ? 1 : 0
            }
        }
    }
    open var thumbShadowOffset: CGSize = CGSize.zero {
        didSet {
            if let thumbView = self.thumbViewIfExist {
                thumbView.layer.shadowOffset = thumbShadowOffset
            }
        }
    }
    open var thumbShadowRadius: CGFloat = 0 {
        didSet {
            if let thumbView = self.thumbViewIfExist {
                thumbView.layer.shadowRadius = thumbShadowRadius
            }
        }
    }
    
    func updateThumbImage() -> Void {
        if self.thumbSize != CGSize.zero {
            let thumbColor: UIColor = self.thumbColor != nil ? self.thumbColor! : self.tintColor
            UIGraphicsBeginImageContextWithOptions(self.thumbSize, false, 0)
            if let context: CGContext = UIGraphicsGetCurrentContext() {
                let path: UIBezierPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: self.thumbSize))
                context.setFillColor(thumbColor.cgColor)
                path.fill()
                let thumbImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.setThumbImage(thumbImage, for: .normal)
                self.setThumbImage(thumbImage, for: .highlighted)
            }
        }
    }
    
}

extension SliderView {
    
    open override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        if self.trackHeight > 0 {
            rect.size.height = self.trackHeight
            rect.origin.y = (bounds.height - rect.height) / 2.0
            return rect
        }
        return rect
    }
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if let thumbView: UIView = self.thumbViewIfExist, thumbView == subview {
            thumbView.layer.shadowColor = self.thumbShadowColor?.cgColor
            thumbView.layer.shadowOpacity = self.thumbShadowColor != nil ? 1 : 0
            thumbView.layer.shadowOffset = self.thumbShadowOffset
            thumbView.layer.shadowRadius = self.thumbShadowRadius
        }
    }
    
    private var thumbViewIfExist: UIView? {
        return self.value(forKey: "thumbView") as? UIView
    }
    
}
