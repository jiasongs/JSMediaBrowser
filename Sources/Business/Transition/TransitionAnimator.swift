//
//  TransitionAnimator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public protocol TransitionAnimatorDelegate: AnyObject {
    
    var transitionSourceView: UIView? { get }
    var transitionSourceRect: CGRect { get }
    var transitionTargetView: UIView? { get }
    var transitionTargetFrame: CGRect { get }
    var transitionThumbImage: UIImage? { get }
    var transitionAnimatorViews: [UIView]? { get }
    
}

public enum TransitionAnimatorType: Int {
    case presenting
    case dismiss
}

public class TransitionAnimator: Transitioner {
    
    public weak var delegate: TransitionAnimatorDelegate?
    public var duration: TimeInterval = 0.25
    public var enteringStyle: TransitioningStyle = .zoom
    public var exitingStyle: TransitioningStyle = .zoom
    
    fileprivate let animationGroupKey: String = "AnimationGroupKey"
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
}

extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let isEntering = self.type == .presenting
        
        self.beginTransition(transitionContext, isEntering: isEntering)
        self.performAnimation(using: transitionContext, isEntering: isEntering) { finished in
            self.endTransition(transitionContext)
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
}

extension TransitionAnimator {
    
    public func performAnimation(using transitionContext: UIViewControllerContextTransitioning, isEntering: Bool, completion: @escaping ((Bool) -> Void)) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        let fromView: UIView = transitionContext.view(forKey: .from) ?? fromViewController.view
        let toView: UIView = transitionContext.view(forKey: .to) ?? toViewController.view
        let containerView: UIView = transitionContext.containerView
        
        /// 最后添加ImageView, 保证在最上层
        self.imageView.removeFromSuperview()
        containerView.addSubview(self.imageView)
        
        var style: TransitioningStyle = isEntering ? self.enteringStyle : self.exitingStyle
        let sourceView = self.delegate?.transitionSourceView
        var sourceRect = CGRect.zero
        if style == .zoom {
            let currentView: UIView = isEntering ? toView : fromView
            if let sourceView = sourceView {
                sourceRect = currentView.convert(sourceView.frame, from: sourceView.superview)
            } else if let transitionSourceRect = self.delegate?.transitionSourceRect {
                sourceRect = currentView.convert(transitionSourceRect, to: currentView)
            }
            /// 判断sourceRect是否与needView相交
            if !sourceRect.isEmpty && !sourceRect.intersects(currentView.frame) {
                sourceRect = CGRect.zero
            }
        }
        
        let contentViewFrame = self.delegate?.transitionTargetFrame ?? CGRect.zero
        style = style == .zoom && (sourceRect.isEmpty || contentViewFrame.isEmpty) ? .fade : style
        
        /// will
        self.handleAnimationEntering(style: style, isEntering: isEntering, fromView: fromView, toView: toView, sourceRect: sourceRect)
        UIView.animate(withDuration: self.duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            /// processing
            self.handleAnimationProcessing(style: style, isEntering: isEntering, fromView: fromView, toView: toView)
        } completion: { (finished) in
            /// did
            self.handleAnimationCompletion(style: style, isEntering: isEntering, fromView: fromView, toView: toView)
            
            completion(finished)
        }
    }
    
}

extension TransitionAnimator {
    
    fileprivate func handleAnimationEntering(style: TransitioningStyle, isEntering: Bool, fromView: UIView, toView: UIView, sourceRect: CGRect) {
        let currentView: UIView? = isEntering ? toView : fromView
        if let animatorViews = self.delegate?.transitionAnimatorViews {
            for view in animatorViews {
                if isEntering {
                    view.alpha = 0.0
                }
            }
        }
        if style == .fade {
            currentView?.alpha = isEntering ? 0 : 1
        } else if style == .zoom {
            let zoomView = self.delegate?.transitionTargetView
            let zoomContentViewFrame = self.delegate?.transitionTargetFrame ?? CGRect.zero
            let zoomContentViewFrameInView = currentView?.convert(zoomContentViewFrame, from: zoomView) ?? CGRect.zero
            let zoomContentViewBoundsInView = CGRect(origin: CGPoint.zero, size: zoomContentViewFrameInView.size)
            /// 隐藏目标视图
            zoomView?.isHidden = true
            /// 设置下Frame
            self.imageView.image = self.delegate?.transitionThumbImage
            self.imageView.frame = isEntering ? sourceRect : zoomContentViewFrameInView
            /// 计算position
            let sourceCenter = CGPoint(x: sourceRect.midX, y: sourceRect.midY)
            let zoomContentViewCenterInView = CGPoint(x: zoomContentViewFrameInView.midX, y: zoomContentViewFrameInView.midY)
            let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
            positionAnimation.fromValue = NSValue(cgPoint: isEntering ? sourceCenter : zoomContentViewCenterInView)
            positionAnimation.toValue = NSValue(cgPoint: isEntering ? zoomContentViewCenterInView : sourceCenter)
            /// 计算bounds
            let sourceBounds = CGRect(origin: CGPoint.zero, size: sourceRect.size)
            let boundsAnimation: CABasicAnimation = CABasicAnimation(keyPath: "bounds")
            boundsAnimation.fromValue = NSValue(cgRect: isEntering ? sourceBounds : zoomContentViewBoundsInView)
            boundsAnimation.toValue = NSValue(cgRect: isEntering ? zoomContentViewBoundsInView : sourceBounds)
            /// 计算cornerRadius
            let cornerRadius: CGFloat = self.delegate?.transitionSourceView?.layer.cornerRadius ?? 0
            let cornerRadiusAnimation: CABasicAnimation = CABasicAnimation(keyPath: "cornerRadius")
            cornerRadiusAnimation.fromValue = isEntering ? cornerRadius : 0
            cornerRadiusAnimation.toValue = isEntering ? 0 : cornerRadius
            /// 添加组动画
            let groupAnimation: CAAnimationGroup  = CAAnimationGroup()
            groupAnimation.duration = self.duration
            groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            groupAnimation.fillMode = .forwards
            groupAnimation.isRemovedOnCompletion = false
            groupAnimation.animations = [positionAnimation, boundsAnimation, cornerRadiusAnimation]
            if #available(iOS 15.0, *) {
                let preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
                groupAnimation.preferredFrameRateRange = preferredFrameRateRange
                groupAnimation.animations?.forEach({ animation in
                    animation.preferredFrameRateRange = preferredFrameRateRange
                })
            }
            self.imageView.layer.add(groupAnimation, forKey: animationGroupKey)
        }
    }
    
    fileprivate func handleAnimationProcessing(style: TransitioningStyle, isEntering: Bool, fromView: UIView, toView: UIView) {
        let currentView: UIView? = isEntering ? toView : fromView
        if let animatorViews = self.delegate?.transitionAnimatorViews {
            for view in animatorViews {
                view.alpha = isEntering ? 1 : 0
            }
        }
        if style == .fade {
            currentView?.alpha = isEntering ? 1 : 0
        }
    }
    
    fileprivate func handleAnimationCompletion(style: TransitioningStyle, isEntering: Bool, fromView: UIView, toView: UIView) {
        let currentView: UIView? = isEntering ? toView : fromView
        if style == .fade {
            currentView?.alpha = 1
        } else if style == .zoom {
            self.delegate?.transitionTargetView?.isHidden = false
        }
        /// 释放资源
        self.imageView.removeFromSuperview()
        self.imageView.layer.removeAnimation(forKey: animationGroupKey)
        self.imageView.image = nil
    }
    
}
