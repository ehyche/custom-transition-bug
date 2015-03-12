//
//  EHDimPresentationController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/8/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHDimPresentationController.h"
#import "EHCustomPresentationDefinitions.h"

static CGFloat const kEHDimAlpha = 0.4;

static CGFloat const kEHDimPresentationControllerDefaultWidthCompact = 280.0;
static CGFloat const kEHDimPresentationControllerDefaultHeightCompact = 400.0;
static CGFloat const kEHDimPresentationControllerDefaultWidthRegular = 600.0;
static CGFloat const kEHDimPresentationControllerDefaultHeightRegular = 700.0;
static CGFloat const kEHDimPresentationControllerMinimumMargin = 20.0;

@interface EHDimPresentationController()

@property(nonatomic, strong) UIView *dimmingView;

@end

@implementation EHDimPresentationController

#pragma mark - EHPresentationController methods

+ (EHCustomPresentationStyle)customPresentationStyle {
    return EHCustomPresentationStyleCustomSizeDimmedBackground;
}

+ (CGSize)defaultPresentedSizeForViewController:(UIViewController *)controller {
    CGSize defaultSize = CGSizeZero;

    if (controller.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        defaultSize = CGSizeMake(kEHDimPresentationControllerDefaultWidthRegular, kEHDimPresentationControllerDefaultHeightRegular);
    } else if (controller.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        defaultSize = CGSizeMake(kEHDimPresentationControllerDefaultWidthCompact, kEHDimPresentationControllerDefaultHeightCompact);
    }

    return defaultSize;
}

#pragma mark - UIPresentationController methods

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController
                         presentingViewController:presentingViewController];
    if (self) {
        // Create the dimming view
        _dimmingView = [[UIView alloc] init];
        _dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kEHDimAlpha];
        _dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
        // Attach a tap gesture recognizer
        UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)];
        [_dimmingView addGestureRecognizer:recog];
    }

    return self;
}

- (void)presentationTransitionWillBegin {
    NSLog(@"presentationTransitionWillBegin");
    // Add the dimming view to the container view
    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.alpha = 0.0;
    // Insert the dimming view at the very bottom
    [self.containerView insertSubview:self.dimmingView atIndex:0];
    // Add the constraints
    NSDictionary *views = @{@"dimmingView" : self.dimmingView};
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dimmingView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dimmingView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views]];
    // Get the transition coordinator
    id<UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    if (coordinator != nil) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                         self.dimmingView.alpha = 1.0;
                                     }
                                     completion:nil];
    } else {
        // We didn't get a transition coordinator, so we can't necessarily
        // transition the showing of the dimming view along with the
        // transition. So we just go ahead and set it to visible.
        self.dimmingView.alpha = 1.0;
    }
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    NSLog(@"presentationTransitionDidEnd:%@", @(completed));
    // If completed = NO, then we did not complete and the presenting controller is still
    // visible and the presented controller is not visible. In that case, we need to
    // remove the dimming view from the container
    if (!completed) {
        self.dimmingView.alpha = 0.0;
        [self.dimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    NSLog(@"dismissalTransitionWillBegin");
    // Get the transition coordinator
    id<UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    if (coordinator != nil) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                         self.dimmingView.alpha = 0.0;
                                     }
                                     completion:nil];
    } else {
        // We didn't get a transition coordinator, so just clear the dimming view
        self.dimmingView.alpha = 0.0;
    }

}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    NSLog(@"dismissalTransitionDidEnd:%@", @(completed));
    // If we completed, then we can remove the dimming view from the container
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyle {
    NSLog(@"adaptivePresentationStyle returns UIModalPresentationOverFullScreen");
    // Not sure when we "become horizontally compact", but we want to still be over full-screen
    return UIModalPresentationOverFullScreen;
}

- (CGRect)frameOfPresentedViewInContainerView {
    // Get the size of the controller
    CGSize controllerSize = self.presentedViewController.preferredContentSize;
    if (CGSizeEqualToSize(controllerSize, CGSizeZero)) {
        UIUserInterfaceSizeClass horzSizeClass = self.presentedViewController.traitCollection.horizontalSizeClass;
        if (horzSizeClass == UIUserInterfaceSizeClassRegular) {
            controllerSize = [EHDimPresentationController defaultSizeForPresentedControllerRegular];
        } else {
            controllerSize = [EHDimPresentationController defaultSizeForPresentedControllerCompact];
        }
    }

    // Get the maximum size inside the container view
    CGRect containerViewBounds = self.containerView.bounds;
    CGRect maxContainerViewFrame = UIEdgeInsetsInsetRect(containerViewBounds, [EHDimPresentationController minimumContainerViewInsets]);

    // Don't let the controller size exceed the maximums
    controllerSize = CGSizeMake(MIN(controllerSize.width, maxContainerViewFrame.size.width),
                                MIN(controllerSize.height, maxContainerViewFrame.size.height));

    // Now center this size inside the containerView
    CGRect presentedViewFrame = CGRectMake(floorf((containerViewBounds.size.width - controllerSize.width) / 2.0),
                                           floorf((containerViewBounds.size.height - controllerSize.height) / 2.0),
                                           controllerSize.width,
                                           controllerSize.height);

    NSLog(@"frameOfPresentedViewInContainerView returns %@", NSStringFromCGRect(presentedViewFrame));

    return presentedViewFrame;
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    NSLog(@"containerViewWillLayoutSubviews");

}

- (void)containerViewDidLayoutSubviews {
    [super containerViewDidLayoutSubviews];
    NSLog(@"containerViewDidLayoutSubviews");

}

#pragma mark - EHDimPresentationController private methods

- (void)dimmingViewTapped:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (CGSize)defaultSizeForPresentedControllerRegular {
    return CGSizeMake(kEHDimPresentationControllerDefaultWidthRegular, kEHDimPresentationControllerDefaultHeightRegular);
}

+ (CGSize)defaultSizeForPresentedControllerCompact {
    return CGSizeMake(kEHDimPresentationControllerDefaultWidthCompact, kEHDimPresentationControllerDefaultHeightCompact);
}

+ (UIEdgeInsets)minimumContainerViewInsets {
    return UIEdgeInsetsMake(kEHDimPresentationControllerMinimumMargin,
                            kEHDimPresentationControllerMinimumMargin,
                            kEHDimPresentationControllerMinimumMargin,
                            kEHDimPresentationControllerMinimumMargin);
}

@end
