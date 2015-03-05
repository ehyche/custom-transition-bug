//
//  GPFadeWithBlurredBackgroundAnimationController.h
//  Groupon
//
//  Created by Eric Hyche on 2/18/15.
//  Copyright (c) 2015 Groupon Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This animation controller:
 *
 *  - Fades in the to view controller in a centered rectangle. The size of
 *    the rectangle is specified by the .preferredContentSize of the to view controller.
 *  - Fades in a blur visual effect background view over the entire container.
 *    If the blur visual effect view is not supported (< iOS 8), then the background
 *    view is just a view with a black background color with 85% opacity.
 */
@interface GPFadeWithBlurredBackgroundAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

/**
 *  View Controllers which are being presented can customize their size
 *  by having a non-CGSizeZero value for .preferredContentSize. However,
 *  if the .preferredCotentSize is not specified, then the size
 *  returned by this class method will be used.
 *
 *  @return Default size for presented view controllers
 */
+ (CGSize)defaultPresentedViewControllerSize;

/**
 *  This property specifies whether the transition is being used for presentation or dismissal.
 *  The default value is NO, meaning it is used for presentation.
 */
@property(nonatomic, assign, getter = isDismissal) BOOL dismissal;

/**
 *  This property specifies the transition duration. The default transition duration is 0.3 seconds.
 */
@property(nonatomic, assign) NSTimeInterval duration;

@end
