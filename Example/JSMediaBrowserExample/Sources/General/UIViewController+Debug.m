//
//  UIViewController+Debug.m
//  JSMediaBrowserExample
//
//  Created by jiasong on 2021/9/19.
//  Copyright © 2021 jiasong. All rights reserved.
//

#import "UIViewController+Debug.h"
#import <QMUIKit/QMUIKit.h>
#if DEBUG
#import <MLeaksFinder/MLeaksFinder.h>
#endif

@implementation UIViewController (Debug)

#if DEBUG
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject addClassNamesToWhitelist:@[@"_UIPageControlContentView"]];
        OverrideImplementation(UIViewController.class, @selector(willDealloc), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject) {
                
                BOOL shouldCallSuper = YES;
                UIViewController *viewController = selfObject.navigationController ? : selfObject;
                if (viewController.beingDismissed) {
                    id<UIViewControllerAnimatedTransitioning> animatedTransitioning = nil;
                    id<UIViewControllerInteractiveTransitioning> interactiveTransitioning = nil;
                    if ([viewController.transitioningDelegate respondsToSelector:@selector(animationControllerForDismissedController:)]) {
                        animatedTransitioning = [viewController.transitioningDelegate animationControllerForDismissedController:viewController];
                    }
                    if ([viewController.transitioningDelegate respondsToSelector:@selector(interactionControllerForDismissal:)]) {
                        interactiveTransitioning = [viewController.transitioningDelegate interactionControllerForDismissal:animatedTransitioning];
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
