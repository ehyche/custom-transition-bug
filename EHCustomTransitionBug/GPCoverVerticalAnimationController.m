//
//  GPCoverVerticalAnimationController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "GPCoverVerticalAnimationController.h"

static NSTimeInterval const kGPCoverVerticalAnimationControllerDefaultDuration = 0.3;

@implementation GPCoverVerticalAnimationController

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = kGPCoverVerticalAnimationControllerDefaultDuration;
    }

    return self;
}

+ (GPCoverVerticalAnimationController *)animationControllerForDismissal:(BOOL)dismissal {
    GPCoverVerticalAnimationController *animationController = [[GPCoverVerticalAnimationController alloc] init];
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

    NSLog(@"XXXMEH GPCoverVerticalAnimationController animateTransition: isDismissal=%@ duration=%@\n\tcontainerView=%@ subviews=%@\n\tfromController=%@\n\ttoController=%@\n\tinitialFrom=%@\n\tinitialTo=%@\n\tfinalFrom=%@\n\tfinalTo=%@\n\tisAnimated=%@",
          @(self.isDismissal), @(animateDuration), containerView, containerView.subviews, fromViewController, toViewController,
          NSStringFromCGRect(initialFrom), NSStringFromCGRect(initialTo),
          NSStringFromCGRect(finalFrom), NSStringFromCGRect(finalTo),
          @(isAnimated));

    // Set up the animation parameters
    UIViewController *viewControllerToAnimate = nil;
    CGRect            startFrame              = CGRectZero;
    CGRect            endFrame                = CGRectZero;
    if (isPresenting) {
        viewControllerToAnimate = toViewController;
        endFrame = finalTo;
        if (CGRectEqualToRect(endFrame, CGRectZero)) {
            endFrame = containerView.bounds;
        }
        startFrame = CGRectMake(endFrame.origin.x,
                                endFrame.origin.y + endFrame.size.height,
                                endFrame.size.width,
                                endFrame.size.height);
    } else {
        viewControllerToAnimate = fromViewController;
        startFrame = initialFrom;
        endFrame = CGRectMake(startFrame.origin.x,
                              startFrame.origin.y + startFrame.size.height,
                              startFrame.size.width,
                              startFrame.size.height);
    }
    UIView *viewToAnimate = viewControllerToAnimate.view;

    // If we are presenting, then we need to add the view to the container
    if (isPresenting) {
        viewToAnimate.frame = containerView.bounds;
        viewToAnimate.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [containerView addSubview:viewToAnimate];
    } else {
        // XXXMEH - workaround
//        toViewController.view.frame = self.presentingViewControllerFrame;
    }

    if (isAnimated) {
        viewToAnimate.frame = startFrame;

        [UIView animateWithDuration:animateDuration
                         animations:^{
                             viewToAnimate.frame = endFrame;
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
