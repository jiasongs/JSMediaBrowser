//
//  TransitionAnimator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(JSMediaBrowserViewControllerTransitionAnimatorDelegate)
public protocol TransitionAnimatorDelegate: NSObjectProtocol {
    
    @objc var transitionSourceRect: CGRect { get }
    @objc weak var transitionSourceView: UIView? { get }
    @objc var transitionCornerRadius: CGFloat { get }
    @objc var transitionThumbImage: UIImage? { get }
    @objc var transitionAnimatorViews: Array<UIView>? { get }
    @objc weak var transitionTargetView: UIView? { get }
    @objc var transitionTargetFrame: CGRect { get }
    
}

@objc(JSMediaBrowserViewControllerTransitionAnimatorType)
public enum TransitionAnimatorType: Int {
    case presenting
    case dismiss
    case push
    case pop
}

@objc(JSMediaBrowserViewControllerTransitionAnimator)
class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    @objc open weak var delegate: TransitionAnimatorDelegate?
    @objc open var duration: TimeInterval = 0.25
    @objc open var enteringStyle: TransitioningStyle = .zoom
    @objc open var exitingStyle: TransitioningStyle = .zoom
    @objc open var animatorType: TransitionAnimatorType = .presenting
    
    private var animationGroupKey: String = "GroupKey"
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let isEntering = self.animatorType == .presenting || self.animatorType == .push
        let presentingViewController = isEntering ? fromViewController : toViewController
        let shouldAppearanceTransitionManually: Bool = presentingViewController?.modalPresentationStyle != UIModalPresentationStyle.fullScreen// 触发背后界面的生命周期，从而配合屏幕旋转那边做一些强制旋转的操作
        
        var style: TransitioningStyle = isEntering ? self.enteringStyle : self.exitingStyle
        let sourceView = self.delegate?.transitionSourceView
        var sourceRect = self.delegate?.transitionSourceRect ?? CGRect.zero
        if style == .zoom {
            let needViewController = isEntering ? toViewController : fromViewController
            if !sourceRect.isEmpty {
                sourceRect = needViewController?.view.convert(sourceRect, from: nil) ?? CGRect.zero
            } else if let sourceView = sourceView {
                sourceRect = needViewController?.view.convert(sourceView.frame, from: sourceView.superview) ?? CGRect.zero
            }
            /// 判断sourceRect是否与needViewController.view相交
            if !sourceRect.isEmpty && !sourceRect.intersects(needViewController?.view.bounds ?? CGRect.zero) {
                sourceRect = CGRect.zero
            }
        }
        
        let containerView: UIView = transitionContext.containerView
        let fromView: UIView? = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let toView: UIView? = transitionContext.view(forKey: UITransitionContextViewKey.to)
        if isEntering {
            if let toView = toView {
                containerView.addSubview(toView)
            }
            if shouldAppearanceTransitionManually {
                presentingViewController?.beginAppearanceTransition(false, animated: true)
            }
        } else {
            if let toView = toView, let fromView = fromView {
                containerView.insertSubview(toView, belowSubview: fromView)
            }
            presentingViewController?.beginAppearanceTransition(true, animated: true)
        }
        /// 强制更新Frame
        fromView?.setNeedsLayout()
        fromView?.layoutIfNeeded()
        toView?.setNeedsLayout()
        toView?.layoutIfNeeded()
        toView?.frame = containerView.bounds
        
        let contentViewFrame = self.delegate?.transitionTargetFrame ?? CGRect.zero
        style = style == .zoom && (sourceRect.isEmpty || contentViewFrame.isEmpty) ? .fade : style
        
        self.handleAnimationEntering(style: style, isEntering: isEntering, fromViewController: fromViewController, toViewController: toViewController, sourceView: sourceView, sourceRect: sourceRect)
        UIView.animate(withDuration: self.duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) {
            self.handleAnimationProcessing(style: style, isEntering: isEntering, fromViewController: fromViewController, toViewController: toViewController, sourceView: sourceView)
        } completion: { (finished) in
            presentingViewController?.endAppearanceTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.handleAnimationCompletion(style: style, isEntering: isEntering, fromViewController: fromViewController, toViewController: toViewController, sourceView: sourceView)
        }
        
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
}

extension TransitionAnimator {
    
    func handleAnimationEntering(style: TransitioningStyle, isEntering: Bool, fromViewController: UIViewController?, toViewController: UIViewController?, sourceView: UIView?, sourceRect: CGRect) -> Void {
        let needViewController = isEntering ? toViewController : fromViewController
        if let toolViews = self.delegate?.transitionAnimatorViews {
            for view in toolViews {
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
                imageView.image = thumbImage
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
            imageView.layer.add(groupAnimation, forKey: animationGroupKey)
        }
    }
    
    func handleAnimationProcessing(style: TransitioningStyle, isEntering: Bool, fromViewController: UIViewController?, toViewController: UIViewController?, sourceView: UIView?) -> Void {
        let needViewController = isEntering ? toViewController : fromViewController
        if let toolViews = self.delegate?.transitionAnimatorViews {
            for view in toolViews {
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
