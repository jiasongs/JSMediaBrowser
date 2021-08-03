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

open class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
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
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        let fromView: UIView? = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let toView: UIView? = transitionContext.view(forKey: UITransitionContextViewKey.to)
        
        let isEntering = self.type == .presenting
        let presentingViewController = isEntering ? fromViewController : toViewController
        let shouldAppearanceTransitionManually: Bool = presentingViewController.modalPresentationStyle != UIModalPresentationStyle.fullScreen
        let containerView: UIView = transitionContext.containerView
        if isEntering {
            if let toView = toView {
                containerView.addSubview(toView)
            }
            if shouldAppearanceTransitionManually {
                presentingViewController.beginAppearanceTransition(false, animated: true)
            }
        } else {
            if let toView = toView, let fromView = fromView {
                containerView.insertSubview(toView, belowSubview: fromView)
            }
            presentingViewController.beginAppearanceTransition(true, animated: true)
        }
        
        /// 强制更新Frame
        fromView?.setNeedsLayout()
        if fromView?.window != nil {
            fromView?.layoutIfNeeded()
        }
        /// 先赋值再强制更新Frame
        toView?.frame = transitionContext.finalFrame(for: toViewController)
        toView?.setNeedsLayout()
        if toView?.window != nil {
            toView?.layoutIfNeeded()
        }
        
        var style: TransitioningStyle = isEntering ? self.enteringStyle : self.exitingStyle
        let sourceView = self.delegate?.transitionSourceView
        var sourceRect = self.delegate?.transitionSourceRect ?? CGRect.zero
        if style == .zoom, let needView: UIView = isEntering ? toView : fromView {
            if !sourceRect.isEmpty {
                sourceRect = needView.convert(sourceRect, from: nil)
            } else if let sourceView = sourceView {
                sourceRect = needView.convert(sourceView.frame, from: sourceView.superview)
            }
            /// 判断sourceRect是否与needView相交
            if !sourceRect.isEmpty && !sourceRect.intersects(needView.frame) {
                sourceRect = CGRect.zero
            }
        }
        
        let contentViewFrame = self.delegate?.transitionTargetFrame ?? CGRect.zero
        style = style == .zoom && (sourceRect.isEmpty || contentViewFrame.isEmpty) ? .fade : style
        
        self.handleAnimationEntering(style: style, isEntering: isEntering, fromViewController: fromViewController, toViewController: toViewController, sourceView: sourceView, sourceRect: sourceRect)
        UIView.animate(withDuration: self.duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.handleAnimationProcessing(style: style, isEntering: isEntering, fromViewController: fromViewController, toViewController: toViewController, sourceView: sourceView)
        } completion: { (finished) in
            if shouldAppearanceTransitionManually || !isEntering {
                presentingViewController.endAppearanceTransition()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.handleAnimationCompletion(style: style, isEntering: isEntering, fromViewController: fromViewController, toViewController: toViewController, sourceView: sourceView)
        }
        
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
}

extension TransitionAnimator {
    
    func handleAnimationEntering(style: TransitioningStyle, isEntering: Bool, fromViewController: UIViewController?, toViewController: UIViewController?, sourceView: UIView?, sourceRect: CGRect) -> Void {
        let needViewController = isEntering ? toViewController : fromViewController
        if let animatorViews = self.delegate?.transitionAnimatorViews {
            for view in animatorViews {
                if isEntering {
                    view.alpha = 0.0
                }
            }
        }
        if style == .fade {
            needViewController?.view.alpha = isEntering ? 0 : 1
        } else if style == .zoom {
            let zoomView = self.delegate?.transitionTargetView
            let zoomContentViewFrame = self.delegate?.transitionTargetFrame ?? CGRect.zero
            let zoomContentViewFrameInView = needViewController?.view.convert(zoomContentViewFrame, from: zoomView) ?? CGRect.zero
            let zoomContentViewBoundsInView = CGRect(origin: CGPoint.zero, size: zoomContentViewFrameInView.size)
            /// 判断是否截取image
            if let thumbImage = self.delegate?.transitionThumbImage {
                self.imageView.image = thumbImage
            }
            /// 隐藏目标视图
            zoomView?.isHidden = true
            /// 添加imageView
            self.imageView.removeFromSuperview()
            needViewController?.view.addSubview(self.imageView)
            /// 设置下Frame
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
    
    func handleAnimationProcessing(style: TransitioningStyle, isEntering: Bool, fromViewController: UIViewController?, toViewController: UIViewController?, sourceView: UIView?) -> Void {
        let needViewController = isEntering ? toViewController : fromViewController
        if let animatorViews = self.delegate?.transitionAnimatorViews {
            for view in animatorViews {
                view.alpha = isEntering ? 1 : 0
            }
        }
        if style == .fade {
            needViewController?.view.alpha = isEntering ? 1 : 0
        }
    }
    
    func handleAnimationCompletion(style: TransitioningStyle, isEntering: Bool, fromViewController: UIViewController?, toViewController: UIViewController?, sourceView: UIView?) -> Void {
        /// 还原设置
        let needViewController = isEntering ? toViewController : fromViewController
        if style == .fade {
            needViewController?.view.alpha = 1
        } else if style == .zoom {
            self.delegate?.transitionTargetView?.isHidden = false
        }
        /// 释放资源
        self.imageView.removeFromSuperview()
        self.imageView.layer.removeAnimation(forKey: animationGroupKey)
        self.imageView.image = nil
    }
    
}
