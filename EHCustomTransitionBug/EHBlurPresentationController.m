//
//  EHBlurPresentationController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/8/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHBlurPresentationController.h"
#import "EHCustomPresentationDefinitions.h"

static CGFloat const kEHBlurPresentationControllerDefaultWidthCompact = 280.0;
static CGFloat const kEHBlurPresentationControllerDefaultHeightCompact = 400.0;
static CGFloat const kEHBlurPresentationControllerDefaultWidthRegular = 600.0;
static CGFloat const kEHBlurPresentationControllerDefaultHeightRegular = 700.0;
static CGFloat const kEHBlurPresentationControllerMinimumMargin = 20.0;

@interface EHBlurPresentationController()

@property(nonatomic, strong) UIVisualEffectView *blurredView;

@end

@implementation EHBlurPresentationController

#pragma mark - EHPresentationController methods

+ (EHCustomPresentationStyle)customPresentationStyle {
    return EHCustomPresentationStyleCustomSizeBlurredBackground;
}

+ (CGSize)defaultPresentedSizeForViewController:(UIViewController *)controller {
    CGSize defaultSize = CGSizeZero;

    if (controller.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        defaultSize = CGSizeMake(kEHBlurPresentationControllerDefaultWidthRegular, kEHBlurPresentationControllerDefaultHeightRegular);
    } else if (controller.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        defaultSize = CGSizeMake(kEHBlurPresentationControllerDefaultWidthCompact, kEHBlurPresentationControllerDefaultHeightCompact);
    }

    return defaultSize;
}

#pragma mark - UIPresentationController methods

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController
                         presentingViewController:presentingViewController];
    if (self) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurredView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        // Attach a tap gesture recognizer
        UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurredViewTapped:)];
        [_blurredView addGestureRecognizer:recog];
    }

    return self;
}

- (void)presentationTransitionWillBegin {
    NSLog(@"presentationTransitionWillBegin");
    // Add the dimming view to the container view
    self.blurredView.frame = self.containerView.bounds;
    self.blurredView.alpha = 0.0;
    // Insert the dimming view at the very bottom
    [self.containerView insertSubview:self.blurredView atIndex:0];
    // Add the constraints
    NSDictionary *views = @{@"blurredView" : self.blurredView};
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurredView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurredView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:views]];
    // Get the transition coordinator
    id<UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    if (coordinator != nil) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.blurredView.alpha = 1.0;
        }
                                     completion:nil];
    } else {
        // We didn't get a transition coordinator, so we can't necessarily
        // transition the showing of the dimming view along with the
        // transition. So we just go ahead and set it to visible.
        self.blurredView.alpha = 1.0;
    }
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    NSLog(@"presentationTransitionDidEnd:%@", @(completed));
    // If completed = NO, then we did not complete and the presenting controller is still
    // visible and the presented controller is not visible. In that case, we need to
    // remove the dimming view from the container
    if (!completed) {
        self.blurredView.alpha = 0.0;
        [self.blurredView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    NSLog(@"dismissalTransitionWillBegin");
    // Get the transition coordinator
    id<UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    if (coordinator != nil) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.blurredView.alpha = 0.0;
        }
                                     completion:nil];
    } else {
        // We didn't get a transition coordinator, so just clear the dimming view
        self.blurredView.alpha = 0.0;
    }

}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    NSLog(@"dismissalTransitionDidEnd:%@", @(completed));
    // If we completed, then we can remove the dimming view from the container
    if (completed) {
        [self.blurredView removeFromSuperview];
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
            controllerSize = [EHBlurPresentationController defaultSizeForPresentedControllerRegular];
        } else {
            controllerSize = [EHBlurPresentationController defaultSizeForPresentedControllerCompact];
        }
    }

    // Get the maximum size inside the container view
    CGRect containerViewBounds = self.containerView.bounds;
    CGRect maxContainerViewFrame = UIEdgeInsetsInsetRect(containerViewBounds, [EHBlurPresentationController minimumContainerViewInsets]);

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

#pragma mark - EHBlurPresentationController private methods

- (void)blurredViewTapped:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (CGSize)defaultSizeForPresentedControllerRegular {
    return CGSizeMake(kEHBlurPresentationControllerDefaultWidthRegular, kEHBlurPresentationControllerDefaultHeightRegular);
}

+ (CGSize)defaultSizeForPresentedControllerCompact {
    return CGSizeMake(kEHBlurPresentationControllerDefaultWidthCompact, kEHBlurPresentationControllerDefaultHeightCompact);
}

+ (UIEdgeInsets)minimumContainerViewInsets {
    return UIEdgeInsetsMake(kEHBlurPresentationControllerMinimumMargin,
                            kEHBlurPresentationControllerMinimumMargin,
                            kEHBlurPresentationControllerMinimumMargin,
                            kEHBlurPresentationControllerMinimumMargin);
}

@end
