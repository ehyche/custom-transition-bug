//
//  GPFadeWithBlurredBackgroundAnimationController.m
//  Groupon
//
//  Created by Eric Hyche on 2/18/15.
//  Copyright (c) 2015 Groupon Inc. All rights reserved.
//

#import "GPFadeWithBlurredBackgroundAnimationController.h"
#import "EHUtilities.h"

NSTimeInterval const kGPFadeWithBlurredBackgroundDefaultDuration = 0.3;

CGFloat const kGPFadeWithBlurredBackgroundDimmedAlpha = 0.50;

CGFloat const kGPFadeWithBlurredBackgroundDefaultWidthCompact = 280.0;
CGFloat const kGPFadeWithBlurredBackgroundDefaultHeightCompact = 400.0;
CGFloat const kGPFadeWithBlurredBackgroundDefaultWidthRegular = 600.0;
CGFloat const kGPFadeWithBlurredBackgroundDefaultHeightRegular = 700.0;

NSInteger const kGPFadeWithBlurredBackgroundDimViewTag = 999;

CGFloat const kGPFadeWithBlurredBackgroundMinMargin = 20.0;

@implementation GPFadeWithBlurredBackgroundAnimationController

#pragma mark - GPFadeWithBlurredBackgroundAnimationController public methods

+ (CGSize)defaultPresentedViewControllerSize {
    CGSize defaultSize = CGSizeZero;

    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
        if (idiom == UIUserInterfaceIdiomPad) {
            defaultSize = CGSizeMake(kGPFadeWithBlurredBackgroundDefaultWidthRegular, kGPFadeWithBlurredBackgroundDefaultHeightRegular);
        } else {
            defaultSize = CGSizeMake(kGPFadeWithBlurredBackgroundDefaultWidthCompact, kGPFadeWithBlurredBackgroundDefaultHeightCompact);
        }
    } else {
        UIUserInterfaceSizeClass horzSizeClass = [[[UIScreen mainScreen] traitCollection] horizontalSizeClass];
        if (horzSizeClass == UIUserInterfaceSizeClassRegular) {
            defaultSize = CGSizeMake(kGPFadeWithBlurredBackgroundDefaultWidthRegular, kGPFadeWithBlurredBackgroundDefaultHeightRegular);
        } else {
            defaultSize = CGSizeMake(kGPFadeWithBlurredBackgroundDefaultWidthCompact, kGPFadeWithBlurredBackgroundDefaultHeightCompact);
        }
    }

    return defaultSize;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = kGPFadeWithBlurredBackgroundDefaultDuration;
    }

    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect initialFrom = [transitionContext initialFrameForViewController:fromController];
    CGRect initialTo = [transitionContext initialFrameForViewController:toController];
    CGRect finalFrom = [transitionContext finalFrameForViewController:fromController];
    CGRect finalTo = [transitionContext finalFrameForViewController:toController];
    BOOL isAnimated = [transitionContext isAnimated];
    NSTimeInterval animateDuration = [self transitionDuration:transitionContext];

    NSLog(@"XXXMEH GPFadeWithBlurredBackgroundAnimationController animateTransition: isDismissal=%@ duration=%@\n\tcontainerView=%@ subviews=%@\n\tfromController=%@\n\ttoController=%@\n\tinitialFrom=%@\n\tinitialTo=%@\n\tfinalFrom=%@\n\tfinalTo=%@\n\tisAnimated=%@",
          @(self.isDismissal), @(animateDuration), containerView, containerView.subviews, fromController, toController,
          NSStringFromCGRect(initialFrom), NSStringFromCGRect(initialTo),
          NSStringFromCGRect(finalFrom), NSStringFromCGRect(finalTo),
          @(isAnimated));

    // Set up the parameters of the transition
    CGFloat alphaInitial = 0.0;
    CGFloat alphaFinal = 0.0;
    UIViewController *controllerToAnimate = nil;
    BOOL shouldRemoveAtCompletion = NO;
    if (self.isDismissal) {
        // In dismissal, the from controller is already on the screen,
        // so we need to remove it.
        controllerToAnimate = fromController;
        // In dismissal we start off at an alpha of 1.0 and animate to an alpha of 0.0
        alphaInitial = 1.0;
        alphaFinal = 0.0;
        // In dismissal, we remove the dimming view and from controller when we're done
        shouldRemoveAtCompletion = YES;
    } else {
        // In presenting, the to controller needs to be put on the screen.
        controllerToAnimate = toController;
        // In presentation, we start off with an alpha of 0.0 and animate to an alpha of 1.0
        alphaInitial = 0.0;
        alphaFinal = 1.0;
        // In presentation, we leave the dimming view and to-controller in the container view at completion
        shouldRemoveAtCompletion = NO;
    }
    // Get the size of the controller
    CGSize controllerSize = controllerToAnimate.preferredContentSize;
    if (CGSizeEqualToSize(controllerSize, CGSizeZero)) {
        controllerSize = [GPFadeWithBlurredBackgroundAnimationController defaultPresentedViewControllerSize];
    }

    // Set up the dimming view
    UIView *dimView = nil;
    if (self.isDismissal) {
        // We are dismissing, so the dimming view should ALREADY be in the containerView,
        // so we just need to find it.
        dimView = [containerView viewWithTag:kGPFadeWithBlurredBackgroundDimViewTag];
    } else {
        dimView = [self dimmingView];
        dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dimView.alpha = alphaInitial;
        dimView.frame = containerView.bounds;
        dimView.tag = kGPFadeWithBlurredBackgroundDimViewTag;
        [containerView addSubview:dimView];
    }

    // Set up the controller view if we are presenting
    if (!self.isDismissal) {
        // Set the controller's initial alpha
        controllerToAnimate.view.alpha = alphaInitial;
        controllerToAnimate.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                                    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        // Compute the frame
        CGSize containerSize = containerView.frame.size;
        CGRect controllerFrame = CGRectMake(floorf((containerSize.width - controllerSize.width) / 2.0),
                                            floorf((containerSize.height - controllerSize.height) / 2.0),
                                            controllerSize.width,
                                            controllerSize.height);
        controllerToAnimate.view.frame = controllerFrame;
        [containerView addSubview:controllerToAnimate.view];
    }

    // Is the presentation or dismissal animated?
    if (isAnimated) {
        // Do the animation and set the alpha values
        [UIView animateWithDuration:animateDuration
                         animations:^{
                             dimView.alpha = alphaFinal;
                             controllerToAnimate.view.alpha = alphaFinal;
                         }
                         completion:^(BOOL finished) {
                             BOOL didFinish = ![transitionContext transitionWasCancelled];
                             // If we are supposed to remove and reset, then do that now
                             if (didFinish && shouldRemoveAtCompletion) {
                                 [dimView removeFromSuperview];
                                 [controllerToAnimate.view removeFromSuperview];
                             }
                             [transitionContext completeTransition:didFinish];
                         }];
    } else {
        // Just set the alphas without animation
        dimView.alpha = alphaFinal;
        controllerToAnimate.view.alpha = alphaFinal;
        // If we are supposed to remove and reset, then do that now
        if (shouldRemoveAtCompletion) {
            [dimView removeFromSuperview];
            [controllerToAnimate.view removeFromSuperview];
        }
        // Tell the transition context we have completed
        [transitionContext completeTransition:YES];
    }
}

#pragma mark - GPFadeWithBlurredBackgroundAnimationController private methods

- (UIView *)dimmingView {
    UIView *viewToReturn = [[UIView alloc] init];
    viewToReturn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kGPFadeWithBlurredBackgroundDimmedAlpha];

    return viewToReturn;
}

@end
