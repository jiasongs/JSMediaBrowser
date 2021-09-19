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

extension TransitionInteractiver: UIViewControllerInteractiveTransitioning {
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.beginTransition(transitionContext, isEntering: self.type == .presenting)
    }
    
}

extension TransitionInteractiver {
    
    public func begin() {
        self.checkInteractiveEnd()
        
        self.isInteractive = true
    }
    
    public func update(_ percentComplete: CGFloat) {
        self.checkInteractiveBegan()
        
        if let context = self.context {
            context.updateInteractiveTransition(percentComplete)
        }
    }
    
    public func finish() {
        self.checkInteractiveBegan()
        
        self.isInteractive = false
        
        if let context = self.context {
            context.finishInteractiveTransition()
            self.endTransition(context, isEntering: self.type == .presenting)
        }
    }
    
    public func cancel() {
        self.checkInteractiveBegan()
        
        self.isInteractive = false
        
        if let context = self.context {
            context.cancelInteractiveTransition()
            self.endTransition(context, isEntering: self.type == .presenting)
        }
    }
    
    fileprivate func checkInteractiveBegan() {
        guard self.isInteractive else {
            fatalError("需要调用begin()")
        }
    }
    
    fileprivate func checkInteractiveEnd() {
        guard !self.isInteractive else {
            fatalError("需要调用finish()或者cancel")
        }
    }
    
}
