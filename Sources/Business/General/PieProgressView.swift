//
//  PieProgressView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit

public enum Shape: Int {
    case sector
    case ring
}

public class PieProgressView: UIControl {
    
    public var animationDuration: CFTimeInterval = 0.5 {
        didSet {
            self.progressLayer.animationDuration = animationDuration
        }
    }
    
    public var progress: Float = 0.0 {
        didSet {
            if needSetProgress {
                self.setProgress(self.progress, animated: false)
            }
        }
    }
    
    public var minimumProgress: Float = 0.0 {
        didSet {
            self.progress = Float(self.progress)
        }
    }
    
    public var borderWidth: CGFloat = 1.0 {
        didSet {
            self.progressLayer.borderWidth = borderWidth
        }
    }
    
    public var borderInset: CGFloat = 3.0 {
        didSet {
            self.progressLayer.borderInset = borderInset
        }
    }
    
    public var lineWidth: CGFloat = 0.0 {
        didSet {
            self.progressLayer.lineWidth = lineWidth
        }
    }
    
    public var shape: Shape = .sector {
        didSet {
            self.progressLayer.shape = shape
            self.borderWidth = CGFloat(borderWidth)
        }
    }
    
    fileprivate var needSetProgress: Bool = true
    
    fileprivate var progressLayer: PieProgressLayer {
        return self.layer as! PieProgressLayer
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
        self.tintColorDidChange()
    }
    
    func didInitialize() {
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.tintColor = UIColor.red
        self.borderWidth = 1.0
        self.borderInset = 3.0
        
        self.progress = 0.0
        self.animationDuration = 0.3
        
        self.progressLayer.contentsScale = UIScreen.main.scale
        self.progressLayer.setNeedsDisplay()
    }
    
}

extension PieProgressView {
    
    public override class var layerClass: AnyClass {
        return PieProgressLayer.self
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        self.progressLayer.fillColor = self.tintColor
        self.progressLayer.strokeColor = self.tintColor
        self.progressLayer.borderColor = self.tintColor.cgColor
    }
    
}

extension PieProgressView {
    
    public func setProgress(_ progress: Float, animated: Bool = true) {
        needSetProgress = false
        self.progress = fmax(self.minimumProgress, fmin(1.0, progress))
        needSetProgress = true
        
        self.progressLayer.shouldChangeProgressWithAnimation = animated
        self.progressLayer.progress = self.progress
        // self.progressLayer.setNeedsDisplay()
        self.sendActions(for: UIControl.Event.valueChanged)
    }
    
}

fileprivate class PieProgressLayer: CALayer {
    
    var shape: Shape = .sector
    @NSManaged var fillColor: UIColor?
    @NSManaged var strokeColor: UIColor?
    @NSManaged var progress: Float
    @NSManaged var lineWidth: CGFloat
    @NSManaged var borderInset: CGFloat
    var animationDuration: CFTimeInterval = 0.5
    var shouldChangeProgressWithAnimation: Bool = true
    
    override class func needsDisplay(forKey key: String) -> Bool {
        return key == #keyPath(progress) || super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == #keyPath(progress) && shouldChangeProgressWithAnimation {
            let animation: CABasicAnimation = CABasicAnimation(keyPath: event)
            animation.fromValue = self.presentation()?.value(forKey: event)
            animation.duration = self.animationDuration
            return animation
        }
        return super.action(forKey: event)
    }
    
    override func draw(in context: CGContext) {
        if self.bounds.isEmpty {
            return
        }
        
        let center: CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
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
        }
        
        super.draw(in: context)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        self.cornerRadius = self.bounds.height / 2
    }
    
}


