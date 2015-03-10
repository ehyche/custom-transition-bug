//
//  EHZoomInAnimationController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/9/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHZoomInAnimationController.h"
#import "EHCustomPresentationDefinitions.h"

static NSTimeInterval const kEHZoomInAnimationControllerDefaultDuration = 0.5;

@implementation EHZoomInAnimationController

#pragma mark - EHViewControllerAnimatedTransitioning methods

@synthesize presenting;
@synthesize duration;

+ (EHCustomTransitionStyle)customTransitionStyle {
    return EHCustomTransitionStyleZoomInWithBounce;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = kEHZoomInAnimationControllerDefaultDuration;
    }

    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect finalTo = [transitionContext finalFrameForViewController:toViewController];
    BOOL isAnimated = [transitionContext isAnimated];
    NSTimeInterval animateDuration = [self transitionDuration:transitionContext];
    BOOL isPresenting = self.isPresenting;

    CGAffineTransform dismissedTransform = CGAffineTransformMakeScale(0.001, 0.001);
    CGAffineTransform presentedTransform = CGAffineTransformIdentity;

    // Set up the animation parameters
    UIViewController *viewControllerToAnimate = nil;
    CGAffineTransform startTransform          = CGAffineTransformIdentity;
    CGAffineTransform endTransform            = CGAffineTransformIdentity;
    if (isPresenting) {
        viewControllerToAnimate = toViewController;
        startTransform          = dismissedTransform;
        endTransform            = presentedTransform;
    } else {
        viewControllerToAnimate = fromViewController;
        startTransform          = presentedTransform;
        endTransform            = dismissedTransform;
    }
    UIView *viewToAnimate = viewControllerToAnimate.view;

    // If we are presenting, then we need to add the view to the container
    if (isPresenting) {
        viewToAnimate.frame = finalTo;
        viewToAnimate.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin  | UIViewAutoresizingFlexibleBottomMargin;
        [containerView addSubview:viewToAnimate];
    }

    if (isAnimated) {
        // Set the initial transform
        viewToAnimate.transform = startTransform;

        [UIView animateWithDuration:animateDuration
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             viewToAnimate.transform = endTransform;
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
