//
//  ZoomBaseView.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/11.
//

import UIKit

public class ZoomBaseView: UIView {
    
    @objc open weak var gestureDelegate: ZoomViewGestureDelegate?
    @objc open var singleTapGesture: UITapGestureRecognizer?
    @objc open var doubleTapGesture: UITapGestureRecognizer?
    @objc open var longPressGesture: UILongPressGestureRecognizer?
    @objc open var dismissingGesture: UIPanGestureRecognizer?
    @objc open var dismissingGestureEnabled: Bool = true
    
    private var gestureBeganLocation: CGPoint = CGPoint.zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    public func didInitialize(frame: CGRect) -> Void {
        self.singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.handleSingleTapGesture))
        self.singleTapGesture?.delegate = self
        self.singleTapGesture?.numberOfTapsRequired = 1
        self.singleTapGesture?.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.singleTapGesture!)
        
        self.doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.handleDoubleTapGesture))
        self.doubleTapGesture?.numberOfTapsRequired = 2
        self.doubleTapGesture?.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.doubleTapGesture!)
        
        self.longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(self.handleLongPressGesture))
        self.longPressGesture?.minimumPressDuration = 1
        self.addGestureRecognizer(self.longPressGesture!)
        
        self.dismissingGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.handleDismissingGesture(gesture:)));
        self.dismissingGesture?.delegate = self
        self.addGestureRecognizer(self.dismissingGesture!)
        
        self.singleTapGesture?.require(toFail: doubleTapGesture!)
        self.singleTapGesture?.require(toFail: self.dismissingGesture!)
        self.doubleTapGesture?.require(toFail: self.dismissingGesture!)
        self.longPressGesture?.require(toFail: self.dismissingGesture!)
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
    
    @objc open func resetDismissingGesture() -> Void {
        self.gestureBeganLocation = CGPoint.zero;
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.containerView?.transform = CGAffineTransform.identity;
        }, completion: nil)
    }
    
}

extension ZoomBaseView: UIGestureRecognizerDelegate {
    
    @objc public func handleSingleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        if let delegate = self.gestureDelegate, delegate.responds(to: #selector(ZoomViewGestureDelegate.zoomingView(_:singleTouch:))) {
            delegate.zoomingView?(self, singleTouch: gestureRecognizer)
        }
    }
    
    @objc public func handleDoubleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        if let delegate = self.gestureDelegate, delegate.responds(to: #selector(ZoomViewGestureDelegate.zoomingView(_:doubleTouch:))) {
            delegate.zoomingView?(self, doubleTouch: gestureRecognizer)
        }
    }
    
    @objc public func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) -> Void {
        if gestureRecognizer.state == .began {
            if let delegate = self.gestureDelegate, delegate.responds(to: #selector(ZoomViewGestureDelegate.zoomingView(_:longPress:))) {
                delegate.zoomingView?(self, longPress: gestureRecognizer)
            }
        }
    }
    
    @objc func handleDismissingGesture(gesture: UIPanGestureRecognizer) -> Void {
        switch gesture.state {
        case .began:
            self.gestureBeganLocation = gesture.location(in: gesture.view)
            self.toggleDismissingGestureDelegate(gesture, verticalDistance: 0)
            break
        case .changed:
            if let containerView = self.containerView {
                let location: CGPoint = gesture.location(in: self)
                let horizontalDistance: CGFloat = location.x - self.gestureBeganLocation.x;
                var verticalDistance: CGFloat = location.y - self.gestureBeganLocation.y;
                var ratio: CGFloat = 1.0;
                if (verticalDistance > 0) {
                    // 往下拉的话，图片缩小，但图片移动距离与手指移动距离保持一致
                    ratio = 1.0 - verticalDistance / self.bounds.height / 2;
                } else {
                    // 往上拉的话，图片不缩小，但手指越往上移动，图片将会越难被拖走
                    let a: CGFloat = self.gestureBeganLocation.y + 70;// 后面这个加数越大，拖动时会越快达到不怎么拖得动的状态
                    let b: CGFloat = 1 - pow((a - abs(verticalDistance)) / a, 2);
                    let contentViewHeight: CGFloat = self.contentViewRectInZoomView().height;
                    let c: CGFloat = (self.bounds.height - contentViewHeight) / 2;
                    verticalDistance = -c * b;
                }
                var transform = CGAffineTransform.init(translationX: horizontalDistance, y: verticalDistance)
                transform = transform.scaledBy(x: ratio, y: ratio);
                containerView.transform = transform;
                self.toggleDismissingGestureDelegate(gesture, verticalDistance: verticalDistance)
            }
            break
        case .ended:
            let location: CGPoint = gesture.location(in: self)
            let verticalDistance: CGFloat = location.y - self.gestureBeganLocation.y;
            self.endDismissingGesture(gesture, verticalDistance: verticalDistance)
            break
        default:
            self.resetDismissingGesture()
            break
        }
    }
    
    func endDismissingGesture(_ gesture: UIPanGestureRecognizer, verticalDistance: CGFloat) -> Void {
        if self.toggleDismissingGestureDelegate(gesture, verticalDistance: verticalDistance) {
            self.gestureBeganLocation = CGPoint.zero;
        } else {
            self.resetDismissingGesture()
        }
    }
    
    @discardableResult
    private func toggleDismissingGestureDelegate(_ gesture: UIPanGestureRecognizer, verticalDistance: CGFloat) -> Bool {
        if let delegate = self.gestureDelegate, delegate.responds(to: #selector(ZoomViewGestureDelegate.zoomingView(_:dismissing:verticalDistance:))) {
            delegate.zoomingView?(self, dismissing: gesture, verticalDistance: verticalDistance)
            return true
        } else {
            return false
        }
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.dismissingGesture {
            let velocity: CGPoint = self.dismissingGesture?.velocity(in: self) ?? CGPoint.zero
            /// 垂直触摸时触发dismiss手势
            if abs(velocity.x) < abs(velocity.y) {
                return dismissingGestureEnabled
            }
            return false
        }
        return true
    }
    
    @objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let delegate = self.gestureDelegate, delegate.responds(to: #selector(ZoomViewGestureDelegate.zoomingView(_:gestureRecognizer:shouldReceive:))) {
            return delegate.zoomingView?(self, gestureRecognizer: gestureRecognizer, shouldReceive: touch) ?? true
        }
        if touch.view != nil && touch.view!.isKind(of: UISlider.self) {
            return false
        }
        return true
    }
    
}

