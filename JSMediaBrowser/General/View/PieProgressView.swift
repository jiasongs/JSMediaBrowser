//
//  PieProgressView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import JSCoreKit

@objc(PieProgressViewShape)
public enum Shape: Int {
    case sector
    case ring
}

@objc open class PieProgressView: UIControl {
    
    fileprivate var progressLayer: PieProgressLayer? {
        return self.layer as? PieProgressLayer
    }
    
    @objc open var progressAnimationDuration: CFTimeInterval = 0.5 {
        didSet {
            self.progressLayer?.progressAnimationDuration = progressAnimationDuration
        }
    }
    @objc open var progress: Float = 0.0 {
        didSet {
            if needSetProgress {
                self.setProgress(progress, animated: false)
            }
        }
    }
    @objc open var borderWidth: CGFloat = 1.0 {
        didSet {
            self.progressLayer?.borderWidth = borderWidth
        }
    }
    @objc open var borderInset: CGFloat = 3.0 {
        didSet {
            self.progressLayer?.borderInset = borderInset
        }
    }
    @objc open var lineWidth: CGFloat = 0.0 {
        didSet {
            self.progressLayer?.lineWidth = lineWidth
        }
    }
    @objc open var shape: Shape = .sector {
        didSet {
            self.progressLayer?.shape = shape
            self.borderWidth = CGFloat(borderWidth)
        }
    }
    
    private var needSetProgress: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
        self.tintColorDidChange()
    }
    
    func didInitialize() -> Void {
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.tintColor = UIColor.red
        self.borderWidth = 1.0
        self.borderInset = 3.0
        
        self.progress = 0.0
        self.progressAnimationDuration = 0.3
        
        self.layer.contentsScale = UIScreen.main.scale
        self.layer.setNeedsDisplay()
    }
    
}

extension PieProgressView {
    
    @objc open func setProgress(_ progress: Float, animated: Bool) -> Void {
        needSetProgress = false
        self.progress = fmax(0.0, fmin(1.0, progress))
        needSetProgress = true
        self.progressLayer?.shouldChangeProgressWithAnimation = animated
        self.progressLayer?.progress = progress
        self.sendActions(for: UIControl.Event.valueChanged)
    }
    
}

extension PieProgressView {
    
    open override class var layerClass: AnyClass {
        return PieProgressLayer.self
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        self.progressLayer?.fillColor = self.tintColor
        self.progressLayer?.strokeColor = self.tintColor
        self.progressLayer?.borderColor = self.tintColor.cgColor
    }
    
}

fileprivate class PieProgressLayer: CALayer {
    
    @NSManaged var fillColor: UIColor?
    @NSManaged var strokeColor: UIColor?
    @NSManaged var progress: Float
    @NSManaged var lineWidth: CGFloat
    @NSManaged var shape: Shape
    @NSManaged var borderInset: CGFloat
    var progressAnimationDuration: CFTimeInterval = 0.5
    var shouldChangeProgressWithAnimation: Bool = true
    
    override class func needsDisplay(forKey key: String) -> Bool {
        return key == #keyPath(progress) || super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == #keyPath(progress) && shouldChangeProgressWithAnimation {
            let animation: CABasicAnimation = CABasicAnimation(keyPath: event)
            animation.fromValue = self.presentation()?.value(forKey: event)
            animation.duration = self.progressAnimationDuration
            return animation
        }
        return super.action(forKey: event)
    }
    
    override func draw(in context: CGContext) {
        if (self.bounds.isEmpty) {
            return
        }
        
        let center: CGPoint = JSCGPointGetCenterWithRect(self.bounds)
        var radius: CGFloat = min(center.x, center.y) - self.borderWidth - self.borderInset
        let startAngle: CGFloat = CGFloat(-Float.pi / 2)
        let endAngle: CGFloat = CGFloat(Float.pi * 2 * self.progress) + startAngle
        
        switch self.shape {
        case .sector:
            // 绘制扇形进度区域
            context.setFillColor(self.fillColor?.cgColor ?? UIColor.red.cgColor)
            context.move(to: center)
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.closePath()
            context.fillPath()
            break
            
        case .ring:
            // 绘制环形进度区域
            radius -= self.lineWidth
            context.setLineWidth(self.lineWidth)
            context.setStrokeColor(self.strokeColor?.cgColor ?? UIColor.red.cgColor)
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.strokePath()
            break
        default:
            break
        }
        
        super.draw(in: context)
    }
    
    override var frame: CGRect {
        didSet {
            self.cornerRadius = self.frame.height / 2
        }
    }
    
    override var bounds: CGRect {
        didSet {
            self.cornerRadius = self.bounds.height / 2
        }
    }
    
}


