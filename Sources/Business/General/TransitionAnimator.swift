//
//  TransitionAnimator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public protocol TransitionAnimatorDelegate: AnyObject {
    
    var transitionSourceRect: CGRect { get }
    var transitionSourceView: UIView? { get }
    var transitionCornerRadius: CGFloat { get }
    var transitionThumbImage: UIImage? { get }
    var transitionAnimatorViews: Array<UIView>? { get }
    var transitionTargetView: UIView? { get }
    var transitionTargetFrame: CGRect { get }
    
}

public enum TransitionAnimatorType: Int {
    case presenting
    case dismiss
}

open class TransitionAnimator: NSObject {
    
    open weak var delegate: TransitionAnimatorDelegate?
    open var duration: TimeInterval = 0.25
    open var enteringStyle: TransitioningStyle = .zoom
    open var exitingStyle: TransitioningStyle = .zoom
    open var type: TransitionAnimatorType = .presenting
    
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
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        let fromView: UIView? = transitionContext.view(forKey: .from)
        let toView: UIView? = transitionContext.view(forKey: .to)
        let containerView: UIView = transitionContext.containerView
        
        /// 添加视图
        let isEntering = self.type == .presenting
        if isEntering {
            if let toView = toView {
                containerView.addSubview(toView)
            }
        } else {
            if let toView = toView, let fromView = fromView {
                containerView.insertSubview(toView, belowSubview: fromView)
            }
        }
        /// 添加ImageView
        self.imageView.removeFromSuperview()
        containerView.addSubview(self.imageView)
        
        /// 触发fromView的布局
        fromView?.setNeedsLayout()
        if fromView?.window != nil {
            fromView?.layoutIfNeeded()
        }
        /// 触发toView的布局
        toView?.frame = transitionContext.finalFrame(for: toViewController)
        toView?.setNeedsLayout()
        if toView?.window != nil {
            toView?.layoutIfNeeded()
        }
        
        /// AppearanceTransition ViewState
        let presentingViewController: UIViewController = isEntering ? fromViewController : toViewController
        let presentedModalPresentationStyle: UIModalPresentationStyle = (isEntering ? toViewController : fromViewController).modalPresentationStyle
        let shouldAppearanceTransitionManually: Bool = (presentedModalPresentationStyle == .custom ||
                                                            presentedModalPresentationStyle == .overFullScreen ||
                                                            presentedModalPresentationStyle == .overCurrentContext)
        /// 其他style会自动调用AppearanceTransition, 这里就不用管了, 否则会触发警告: Unbalanced calls to begin/end
        if shouldAppearanceTransitionManually {
            presentingViewController.beginAppearanceTransition(!isEntering, animated: true)
        }
        
        var style: TransitioningStyle = isEntering ? self.enteringStyle : self.exitingStyle
        let sourceView = self.delegate?.transitionSourceView
        var sourceRect = self.delegate?.transitionSourceRect ?? CGRect.zero
        if style == .zoom, let currentView: UIView = isEntering ? toView : fromView {
            if !sourceRect.isEmpty {
                sourceRect = currentView.convert(sourceRect, to: currentView)
            } else if let sourceView = sourceView {
                sourceRect = currentView.convert(sourceView.frame, from: sourceView.superview)
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
            if shouldAppearanceTransitionManually {
                presentingViewController.endAppearanceTransition()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            /// did
            self.handleAnimationCompletion(style: style, isEntering: isEntering, fromView: fromView, toView: toView)
        }
        
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
}

extension TransitionAnimator {
    
    func handleAnimationEntering(style: TransitioningStyle, isEntering: Bool, fromView: UIView?, toView: UIView?, sourceRect: CGRect) -> Void {
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
            let cornerRadius: CGFloat = self.delegate?.transitionCornerRadius ?? 0
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
            self.imageView.layer.add(groupAnimation, forKey: animationGroupKey)
        }
    }
    
    func handleAnimationProcessing(style: TransitioningStyle, isEntering: Bool, fromView: UIView?, toView: UIView?) -> Void {
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
    
    func handleAnimationCompletion(style: TransitioningStyle, isEntering: Bool, fromView: UIView?, toView: UIView?) -> Void {
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
