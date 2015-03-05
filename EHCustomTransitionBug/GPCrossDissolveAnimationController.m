//
//  GPCrossDissolveAnimationController.m
//  Groupon
//
//  Created by Eric Hyche on 3/4/15.
//  Copyright (c) 2015 Groupon Inc. All rights reserved.
//

#import "GPCrossDissolveAnimationController.h"

static NSTimeInterval const kGPCrossDissolveAnimationControllerDefaultDuration = 0.3;

@implementation GPCrossDissolveAnimationController

#pragma mark - GPCrossDissolveAnimationController public methods

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = kGPCrossDissolveAnimationControllerDefaultDuration;
    }

    return self;
}

+ (GPCrossDissolveAnimationController *)animationControllerForDismissal:(BOOL)dismissal {
    GPCrossDissolveAnimationController *animationController = [[GPCrossDissolveAnimationController alloc] init];
    animationController.dismissal = dismissal;
    return animationController;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect initialFrom = [transitionContext initialFrameForViewController:fromViewController];
    CGRect initialTo = [transitionContext initialFrameForViewController:toViewController];
    CGRect finalFrom = [transitionContext finalFrameForViewController:fromViewController];
    CGRect finalTo = [transitionContext finalFrameForViewController:toViewController];
    BOOL isAnimated = [transitionContext isAnimated];
    NSTimeInterval animateDuration = [self transitionDuration:transitionContext];
    BOOL isPresenting = !self.isDismissal;

    NSLog(@"XXXMEH GPCrossDissolveAnimationController animateTransition: isDismissal=%@ duration=%@\n\tcontainerView=%@ subviews=%@\n\tfromController=%@\n\ttoController=%@\n\tinitialFrom=%@\n\tinitialTo=%@\n\tfinalFrom=%@\n\tfinalTo=%@\n\tisAnimated=%@",
          @(self.isDismissal), @(animateDuration), containerView, containerView.subviews, fromViewController, toViewController,
          NSStringFromCGRect(initialFrom), NSStringFromCGRect(initialTo),
          NSStringFromCGRect(finalFrom), NSStringFromCGRect(finalTo),
          @(isAnimated));

    // Set up the animation parameters
    UIViewController *viewControllerToAnimate = nil;
    CGFloat           initialAlpha            = 0.0;
    CGFloat           finalAlpha              = 0.0;
    if (isPresenting) {
        viewControllerToAnimate = toViewController;
        initialAlpha = 0.0;
        finalAlpha = 1.0;
    } else {
        viewControllerToAnimate = fromViewController;
        initialAlpha = 1.0;
        finalAlpha = 0.0;
    }
    UIView *viewToAnimate = viewControllerToAnimate.view;

    // If we are presenting, then we need to add the view to the container
    if (isPresenting) {
        viewToAnimate.frame = containerView.bounds;
        viewToAnimate.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [containerView addSubview:viewToAnimate];
    }

    if (isAnimated) {
        // Set the initial alpha
        viewToAnimate.alpha = initialAlpha;
        
        [UIView animateWithDuration:animateDuration
                         animations:^{
                             viewToAnimate.alpha = finalAlpha;
                         }
                         completion:^(BOOL finished) {
                             BOOL didComplete = ![transitionContext transitionWasCancelled];
                             // We need to remove the view we are animating from the container if:
                             // - We completed and we were dismissing; OR
                             // - We didn't complete and we were presenting.
                             BOOL shouldRemove = ((didComplete && !isPresenting) || (!didComplete && isPresenting));
                             if (shouldRemove) {
                                 [viewToAnimate removeFromSuperview];
                             }
                             // Tell the transition context we finished
                             [transitionContext completeTransition:didComplete];
                         }];
    } else {
        // We are not animated.
        //
        // - If presenting, just add the view of the to-controller to the container. We have already done this above.
        // - If dismissing, just remove the view of from-controller from the container
        if (!isPresenting) {
            [viewToAnimate removeFromSuperview];
        }
        // Tell the transition context we have completed
        [transitionContext completeTransition:YES];
    }
}

@end
