//
//  UIViewController+Debug.m
//  JSMediaBrowserExample
//
//  Created by jiasong on 2021/9/19.
//  Copyright © 2021 jiasong. All rights reserved.
//

#import "UIViewController+Debug.h"
#import <QMUIKit/QMUIKit.h>
#ifdef DEBUG
#import <MLeaksFinder/MLeaksFinder.h>
#endif

@implementation UIViewController (Debug)

#ifdef DEBUG
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIViewController class], @selector(willDealloc), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject) {
                BOOL shouldCallSuper = YES;
                
                if (selfObject.beingDismissed && [selfObject conformsToProtocol:@protocol(UIViewControllerTransitioningDelegate)]) {
                    id<UIViewControllerTransitioningDelegate> transitionViewController = (id<UIViewControllerTransitioningDelegate>)selfObject;
                    id<UIViewControllerAnimatedTransitioning> animatedTransitioning = nil;
                    id<UIViewControllerInteractiveTransitioning> interactiveTransitioning = nil;
                    if ([transitionViewController respondsToSelector:@selector(animationControllerForDismissedController:)]) {
                        animatedTransitioning = [(id<UIViewControllerTransitioningDelegate>)selfObject animationControllerForDismissedController:selfObject];
                    }
                    if ([transitionViewController respondsToSelector:@selector(interactionControllerForDismissal:)]) {
                        interactiveTransitioning =  [(id<UIViewControllerTransitioningDelegate>)selfObject interactionControllerForDismissal:animatedTransitioning];
                    }
                    if (interactiveTransitioning != nil) {
                        shouldCallSuper = NO;
                    }
                }
                
                if (shouldCallSuper) {
                    // call super
                    void (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD);
                }
            };
        });
    });
}
#endif

@end
