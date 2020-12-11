//
//  ZoomBaseView.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/11.
//

import UIKit

public class ZoomBaseView: UIView {
    
    open weak var delegate: ZoomViewProtocol?
    open var singleTapGesture: UITapGestureRecognizer?
    open var doubleTapGesture: UITapGestureRecognizer?
    open var longPressGesture: UILongPressGestureRecognizer?
    
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
        self.longPressGesture?.numberOfTapsRequired = 2
        self.longPressGesture?.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.longPressGesture!)
        
        self.singleTapGesture?.require(toFail: doubleTapGesture!)
    }
    
}

extension ZoomBaseView: UIGestureRecognizerDelegate {
    
    @objc public func handleSingleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        if let delegate = self.delegate, delegate.responds(to: #selector(ZoomViewProtocol.zoomingView(_:singleTouch:))) {
            delegate.zoomingView?(self, singleTouch: gestureRecognizer)
        }
    }
    
    @objc public func handleDoubleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        if let delegate = self.delegate, delegate.responds(to: #selector(ZoomViewProtocol.zoomingView(_:doubleTouch:))) {
            delegate.zoomingView?(self, doubleTouch: gestureRecognizer)
        }
    }
    
    @objc public func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) -> Void {
        if let delegate = self.delegate, delegate.responds(to: #selector(ZoomViewProtocol.zoomingView(_:longPress:))) {
            delegate.zoomingView?(self, longPress: gestureRecognizer)
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let delegate = self.delegate, delegate.responds(to: #selector(ZoomViewProtocol.zoomingView(_:gestureRecognizer:shouldReceive:))) {
            return delegate.zoomingView?(self, gestureRecognizer: gestureRecognizer, shouldReceive: touch) ?? true
        }
        if touch.view != nil && touch.view!.isKind(of: UISlider.self) {
            return false
        }
        return true
    }
    
}
