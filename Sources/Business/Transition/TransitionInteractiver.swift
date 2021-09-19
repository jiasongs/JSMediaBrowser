//
//  TransitionInteractiver.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/9/17.
//

import UIKit

public enum TransitionInteractiverType: Int {
    case presenting
    case dismiss
}

public class TransitionInteractiver: Transitioner {
    
    open var type: TransitionInteractiverType = .presenting
    
    internal var isInteractive: Bool = false
    
}

extension TransitionInteractiver {
    
    public func begin() {
        self.isInteractive = true
    }
    
    public func update(_ percentComplete: CGFloat) {
        guard let context = self.context else {
            return
        }
        
        context.updateInteractiveTransition(percentComplete)
    }
    
    public func finish() {
        guard let context = self.context else {
            return
        }
        
        self.isInteractive = false
        context.finishInteractiveTransition()
        self.endTransition(context, isEntering: self.type == .presenting)
    }
    
    public func cancel() {
        guard let context = self.context else {
            return
        }
        
        self.isInteractive = false
        context.cancelInteractiveTransition()
        self.endTransition(context, isEntering: self.type == .presenting)
    }
    
}

extension TransitionInteractiver: UIViewControllerInteractiveTransitioning {
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.beginTransition(transitionContext, isEntering: self.type == .presenting)
    }
    
}
