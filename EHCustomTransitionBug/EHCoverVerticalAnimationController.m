//
//  EHCoverVerticalAnimationController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/9/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHCoverVerticalAnimationController.h"
#import "EHCustomPresentationDefinitions.h"

static NSTimeInterval const kEHCoverVerticalAnimationControllerDefaultDuration = 0.3;

@implementation EHCoverVerticalAnimationController

#pragma mark - EHViewControllerAnimatedTransitioning methods

@synthesize presenting;
@synthesize duration;

+ (EHCustomTransitionStyle)customTransitionStyle {
    return EHCustomTransitionStyleCoverVertical;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = kEHCoverVerticalAnimationControllerDefaultDuration;
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
    CGRect initialFrom = [transitionContext initialFrameForViewController:fromViewController];
    CGRect finalTo = [transitionContext finalFrameForViewController:toViewController];
    BOOL isAnimated = [transitionContext isAnimated];
    NSTimeInterval animateDuration = [self transitionDuration:transitionContext];
    BOOL isPresenting = self.isPresenting;
    CGFloat containerHeight = containerView.frame.size.height;

    // Set up the animation parameters
    UIViewController *viewControllerToAnimate = nil;
    CGRect            startFrame              = CGRectZero;
    CGRect            endFrame                = CGRectZero;
    if (isPresenting) {
        viewControllerToAnimate = toViewController;
        endFrame = finalTo;
        // Start it off down just below the container view
        startFrame = CGRectMake(endFrame.origin.x,
                                containerHeight,
                                endFrame.size.width,
                                endFrame.size.height);
    } else {
        viewControllerToAnimate = fromViewController;
        startFrame = initialFrom;
        endFrame = CGRectMake(startFrame.origin.x,
                              containerHeight,
                              startFrame.size.width,
                              startFrame.size.height);
    }
    UIView *viewToAnimate = viewControllerToAnimate.view;

    // If we are presenting, then we need to add the view to the container
    if (isPresenting) {
        viewToAnimate.frame = startFrame;
        viewToAnimate.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                         UIViewAutoresizingFlexibleTopMargin  | UIViewAutoresizingFlexibleBottomMargin;
        [containerView addSubview:viewToAnimate];
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
