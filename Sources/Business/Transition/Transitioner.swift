//
//  Transitioner.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/9/17.
//

import UIKit

open class Transitioner: NSObject {
    
    open weak var context: UIViewControllerContextTransitioning?
    
    fileprivate var shouldAppearanceTransitionManually: Bool = false
    
    #if DEBUG
    fileprivate var isCallCompleteTransitions: [Int: Bool] = [:]
    #endif
    
    public override init() {
        super.init()
    }
    
    deinit {
        #if DEBUG
        for (_, value) in self.isCallCompleteTransitions {
            assert(value, "未调用completion回调, 可能存在问题, 请检查代码")
        }
        #endif
    }
    
}

extension Transitioner {
    
    public func beginTransition(_ transitionContext: UIViewControllerContextTransitioning, isEntering: Bool) {
        self.context = transitionContext
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        let fromView: UIView = transitionContext.view(forKey: .from) ?? fromViewController.view
        let toView: UIView = transitionContext.view(forKey: .to) ?? toViewController.view
        let containerView: UIView = transitionContext.containerView
        
        /// 添加视图
        if isEntering {
            if toView.superview == nil {
                containerView.addSubview(toView)
            }
        } else {
            if toView.superview == nil && fromView.superview == containerView {
                containerView.insertSubview(toView, belowSubview: fromView)
            }
        }
        
        /// 触发fromView的布局
        fromView.setNeedsLayout()
        if fromView.window != nil {
            fromView.layoutIfNeeded()
        }
        let finalFrame: CGRect = transitionContext.finalFrame(for: toViewController)
        /// dismiss时finalFrame可能与原视图的frame不一致, 导致一些UI异常
        if !finalFrame.isEmpty && isEntering {
            toView.frame = transitionContext.finalFrame(for: toViewController)
        }
        /// 触发toView的布局
        toView.setNeedsLayout()
        if toView.window != nil {
            toView.layoutIfNeeded()
        }
        
        /// AppearanceTransition ViewState
        let presentingViewController: UIViewController = isEntering ? fromViewController : toViewController
        let presentedModalPresentationStyle: UIModalPresentationStyle = (isEntering ? toViewController : fromViewController).modalPresentationStyle
        self.shouldAppearanceTransitionManually = (presentedModalPresentationStyle == .custom ||
                                                    presentedModalPresentationStyle == .overFullScreen ||
                                                    presentedModalPresentationStyle == .overCurrentContext)
        /// 其他style会自动调用AppearanceTransition, 这里就不用管了, 否则会触发警告: Unbalanced calls to begin/end
        if self.shouldAppearanceTransitionManually {
            presentingViewController.beginAppearanceTransition(!isEntering, animated: true)
        }
        
        #if DEBUG
        self.isCallCompleteTransitions[isEntering ? 0 : 1] = false
        #endif
    }
    
    public func endTransition(_ transitionContext: UIViewControllerContextTransitioning, isEntering: Bool) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let presentingViewController: UIViewController = isEntering ? fromViewController : toViewController
        if self.shouldAppearanceTransitionManually {
            self.shouldAppearanceTransitionManually = false
            presentingViewController.endAppearanceTransition()
        }
        
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        
        #if DEBUG
        self.isCallCompleteTransitions[isEntering ? 0 : 1] = true
        #endif
    }
    
}
