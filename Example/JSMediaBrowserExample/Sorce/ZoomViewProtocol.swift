//
//  ZoomViewProtocol.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/11.
//

import UIKit

@objc public protocol ZoomViewProtocol: NSObjectProtocol {
    
    @objc optional func zoomingView(_ zoomingView: ZoomBaseView, singleTouch gestureRecognizer: UITapGestureRecognizer)
    @objc optional func zoomingView(_ zoomingView: ZoomBaseView, doubleTouch gestureRecognizer: UITapGestureRecognizer)
    @objc optional func zoomingView(_ zoomingView: ZoomBaseView, longPress gestureRecognizer: UILongPressGestureRecognizer)
    @objc optional func zoomingView(_ zoomingView: ZoomBaseView, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    
}
