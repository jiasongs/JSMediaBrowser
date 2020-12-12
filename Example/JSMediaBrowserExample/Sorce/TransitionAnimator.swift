//
//  TransitionAnimator.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit
import JSCoreKit

@objc public protocol TransitionAnimatorDelegate: NSObjectProtocol {
    
    @objc var sourceRect: CGRect { get }
    @objc weak var sourceView: UIView? { get }
    @objc var sourceCornerRadius: CGFloat { get }
    @objc weak var contentView: UIView? { get }
    @objc weak var zoomView: UIView? { get }
    @objc weak var zoomContentView: UIView? { get }
    @objc var zoomViewContentRect: CGRect { get }
    
}

@objc(MediaBrowserViewControllerTransitionAnimator)
class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    @objc open weak var delegate: TransitionAnimatorDelegate?
    @objc open var duration: TimeInterval = 0.25
    @objc open var presentingStyle: TransitioningStyle = .zoom {
        didSet {
            dismissingStyle = presentingStyle
        }
    }
    @objc open var dismissingStyle: TransitioningStyle = .zoom
    
    private var animationTransformKey: String = "TransformKey"
    private var animationMaskGroupKey: String = "MaskGroupKey"
    private var cornerRadiusMaskLayer: CALayer?
    
    override init() {
        super.init()
        self.cornerRadiusMaskLayer = CALayer.init();
        self.cornerRadiusMaskLayer?.js_removeDefaultAnimations()
        self.cornerRadiusMaskLayer?.backgroundColor = UIColor.white.cgColor;
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let isPresenting = fromViewController?.presentedViewController == toViewController;
        let presentingViewController = isPresenting ? fromViewController : toViewController;
        let shouldAppearanceTransitionManually: Bool = presentingViewController?.modalPresentationStyle != UIModalPresentationStyle.fullScreen;// 触发背后界面的生命周期，从而配合屏幕旋转那边做一些强制旋转的操作
        
        var style: TransitioningStyle = isPresenting ? self.presentingStyle : self.dismissingStyle;
        let sourceView = self.delegate?.sourceView
        var sourceRect = self.delegate?.sourceRect ?? CGRect.zero
        if style == .zoom {
            let needViewController = isPresenting ? toViewController : fromViewController;
            if sourceView != nil {
                sourceRect = needViewController?.view.convert(sourceView!.frame, from: sourceView!.superview) ?? CGRect.zero
            } else {
                sourceRect = needViewController?.view.convert(sourceRect, from: nil) ?? CGRect.zero
            }
            if (!sourceRect.isEmpty && !sourceRect.intersects(needViewController?.view.bounds ?? CGRect.zero)) {
                sourceRect = CGRect.zero;
            }
        }
        style = style == .zoom && sourceRect.isEmpty ? .fade : style;
        
        let containerView: UIView = transitionContext.containerView
        let fromView: UIView? = transitionContext.view(forKey: UITransitionContextViewKey.from)
        fromView?.setNeedsLayout()
        fromView?.layoutIfNeeded()
        let toView: UIView? = transitionContext.view(forKey: UITransitionContextViewKey.to)
        toView?.setNeedsLayout()
        toView?.layoutIfNeeded()
        toView?.frame = containerView.bounds;
        if (isPresenting) {
            if toView != nil {
                containerView.addSubview(toView!)
            }
            if shouldAppearanceTransitionManually {
                presentingViewController?.beginAppearanceTransition(false, animated: true)
            }
        } else {
            if toView != nil && fromView != nil {
                containerView.insertSubview(toView!, belowSubview: fromView!)
            }
            presentingViewController?.beginAppearanceTransition(true, animated: true)
        }
        
        self.handleAnimationEntering(style: style, isPresenting: isPresenting, fromViewController: fromViewController, toViewController: toViewController, sourceRect: sourceRect)
        UIView.animate(withDuration: self.duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.handleAnimationProcessing(style: style, isPresenting: isPresenting, fromViewController: fromViewController, toViewController: toViewController)
        } completion: { (finished) in
            presentingViewController?.endAppearanceTransition();
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.handleAnimationCompletion(style: style, isPresenting: isPresenting, fromViewController: fromViewController, toViewController: toViewController)
        }
        
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
}

extension TransitionAnimator {
    
    func handleAnimationEntering(style: TransitioningStyle, isPresenting: Bool, fromViewController: UIViewController?, toViewController: UIViewController?, sourceRect: CGRect) -> Void {
        let needViewController = isPresenting ? toViewController : fromViewController;
        if style == .fade {
            needViewController?.view.alpha = isPresenting ? 0 : 1;
        } else if style == .zoom {
            let contentView = self.delegate?.contentView;
            let zoomView = self.delegate?.zoomView
            let zoomViewContentRect = self.delegate?.zoomViewContentRect ?? CGRect.zero
            let zoomContentView = self.delegate?.zoomContentView
            var zoomContentViewFrame = needViewController?.view.convert(zoomViewContentRect, to: nil) ?? CGRect.zero;
            var zoomContentViewCenterInZoomView: CGPoint = JSCGPointGetCenterWithRect(zoomViewContentRect);
            if (zoomContentViewFrame.isEmpty) {
                if let zoomView = self.delegate?.zoomView {
                    zoomContentViewFrame = needViewController?.view.convert(zoomView.frame, from: zoomView.superview) ?? CGRect.zero
                }
                zoomContentViewCenterInZoomView = JSCGPointGetCenterWithRect(zoomContentViewFrame);
            }
            let centerInZoomView: CGPoint = JSCGPointGetCenterWithRect(zoomView?.bounds ?? CGRect.zero);
            let horizontalRatio: CGFloat = sourceRect.width / zoomContentViewFrame.width;
            let verticalRatio: CGFloat = sourceRect.height / zoomContentViewFrame.height;
            let finalRatio: CGFloat = max(horizontalRatio, verticalRatio);
            
            var fromTransform: CGAffineTransform = CGAffineTransform.identity;
            var toTransform: CGAffineTransform = CGAffineTransform.identity;
            var transform: CGAffineTransform = CGAffineTransform.init(scaleX: finalRatio, y: finalRatio);
        
            let contentViewCenterAfterScale: CGPoint = CGPoint.init(x: centerInZoomView.x + (zoomContentViewCenterInZoomView.x - centerInZoomView.x) * finalRatio, y: centerInZoomView.y + (zoomContentViewCenterInZoomView.y - centerInZoomView.y) * finalRatio)
            let translationAfterScale: CGSize = CGSize.init(width: sourceRect.midX - contentViewCenterAfterScale.x, height: sourceRect.midY - contentViewCenterAfterScale.y)
            transform = transform.concatenating(CGAffineTransform.init(translationX: translationAfterScale.width, y: translationAfterScale.height))
            
            if (isPresenting) {
                fromTransform = transform;
            } else {
                toTransform = transform;
            }
            
            var maskFromBounds: CGRect = zoomContentView?.bounds ?? CGRect.zero
            var maskToBounds: CGRect = zoomContentView?.bounds ?? CGRect.zero
            var maskBounds: CGRect = maskFromBounds;
            let maskHorizontalRatio: CGFloat = sourceRect.width / maskBounds.width;
            let maskVerticalRatio: CGFloat = sourceRect.height / maskBounds.height;
            let maskFinalRatio: CGFloat = max(maskHorizontalRatio, maskVerticalRatio);
            maskBounds = JSCGRectMakeWithSize(CGSize.init(width: sourceRect.width / maskFinalRatio, height: sourceRect.height / maskFinalRatio));
            if (isPresenting) {
                maskFromBounds = maskBounds;
            } else {
                maskToBounds = maskBounds;
            }
            
            let cornerRadius: CGFloat = self.delegate?.sourceCornerRadius ?? 0 / maskFinalRatio;
            let fromCornerRadius = isPresenting ? cornerRadius : 0;
            let toCornerRadius = isPresenting ? 0 : cornerRadius;
            let cornerRadiusAnimation: CABasicAnimation = CABasicAnimation.init(keyPath: "cornerRadius")
            cornerRadiusAnimation.fromValue = fromCornerRadius;
            cornerRadiusAnimation.toValue = toCornerRadius;
            
            let boundsAnimation: CABasicAnimation = CABasicAnimation.init(keyPath: "bounds")
            boundsAnimation.fromValue = NSValue.init(cgRect: JSCGRectMakeWithSize(maskFromBounds.size))
            boundsAnimation.toValue = NSValue.init(cgRect: JSCGRectMakeWithSize(maskToBounds.size))
            
            let maskAnimation: CAAnimationGroup  = CAAnimationGroup.init();
            maskAnimation.duration = self.duration;
            maskAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
            maskAnimation.fillMode = .forwards;
            maskAnimation.isRemovedOnCompletion = false;
            maskAnimation.animations = [cornerRadiusAnimation, boundsAnimation];
            self.cornerRadiusMaskLayer?.position = JSCGPointGetCenterWithRect(zoomContentView?.bounds ?? CGRect.zero);// 不管怎样，mask 都是居中的
            zoomContentView?.layer.mask = self.cornerRadiusMaskLayer;
            self.cornerRadiusMaskLayer?.add(maskAnimation, forKey: animationMaskGroupKey)
            
            if (isPresenting) {
                zoomView?.transform = fromTransform;
                contentView?.backgroundColor = UIColor.init(white: 0, alpha: 0)
            }
            
            let transformAnimation: CABasicAnimation = CABasicAnimation.init(keyPath: "transform")
            transformAnimation.toValue = NSValue.init(caTransform3D: CATransform3DMakeAffineTransform(toTransform))
            transformAnimation.duration = self.duration;
            transformAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
            transformAnimation.fillMode = .forwards;
            transformAnimation.isRemovedOnCompletion = false;
            zoomView?.layer.add(transformAnimation, forKey: animationTransformKey)
        }
    }
    
    func handleAnimationProcessing(style: TransitioningStyle, isPresenting: Bool, fromViewController: UIViewController?, toViewController: UIViewController?) -> Void {
        let needViewController = isPresenting ? toViewController : fromViewController;
        if style == .fade {
            needViewController?.view.alpha = isPresenting ? 1 : 0;
        } else if style == .zoom {
            if let contentView = self.delegate?.contentView {
                let color: UIColor = contentView.backgroundColor?.withAlphaComponent(1) ?? UIColor.init(white: 0, alpha: 0)
                contentView.backgroundColor = isPresenting ? color : UIColor.init(white: 0, alpha: 0);
            }
        }
    }
    
    func handleAnimationCompletion(style: TransitioningStyle, isPresenting: Bool, fromViewController: UIViewController?, toViewController: UIViewController?) -> Void {
        let needViewController = isPresenting ? fromViewController : toViewController;
        // for fade
        needViewController?.view.alpha = 1;
        
        // for zoom
        let zoomView = self.delegate?.zoomView
        zoomView?.transform = CGAffineTransform.identity
        zoomView?.layer.removeAnimation(forKey: animationTransformKey)
        
        self.cornerRadiusMaskLayer?.removeAnimation(forKey: animationMaskGroupKey)
        self.delegate?.zoomContentView?.layer.mask = nil;
    }
    
}
