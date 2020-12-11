//
//  ZoomBaseView.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/11.
//

import UIKit

public class ZoomBaseView: UIView {
    
    open var singleTapGesture: UITapGestureRecognizer!
    open var doubleTapGesture: UITapGestureRecognizer!
    open var longPressGesture: UILongPressGestureRecognizer!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    public func didInitialize(frame: CGRect) -> Void {
        self.singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.handleSingleTapGestureWithPoint))
        self.singleTapGesture.delegate = self
        self.singleTapGesture.numberOfTapsRequired = 1
        self.singleTapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.singleTapGesture)
        
        self.doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.handleDoubleTapGestureWithPoint))
        self.doubleTapGesture.numberOfTapsRequired = 2
        self.doubleTapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.doubleTapGesture)
        
        self.longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(self.handleLongPressGesture))
        self.longPressGesture.numberOfTapsRequired = 2
        self.longPressGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.longPressGesture)
        
        // 双击失败后才出发单击
        self.singleTapGesture.require(toFail: doubleTapGesture)
    }
    
}

extension ZoomBaseView: UIGestureRecognizerDelegate {
    
    @objc public func handleSingleTapGestureWithPoint(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        
    }
    
    @objc public func handleDoubleTapGestureWithPoint(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        
    }
    
    @objc public func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) -> Void {
        
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != nil && touch.view!.isKind(of: UISlider.self) {
            return false
        }
        return true
    }
    
}
