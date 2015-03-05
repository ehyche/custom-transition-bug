//
//  GPCrossDissolveAnimationController.h
//  Groupon
//
//  Created by Eric Hyche on 3/4/15.
//  Copyright (c) 2015 Groupon Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This animation controller:
 *
 *  - Is a custom transition lookalike for .modalTransitionStyle = UIModalTransitionStyleCrossDissolve
 *  - On presentation, it fades in the to-controller from alpha = 0.0 to alpha = 1.0
 *  - On dismissal, it fades out the from-controller from alpha = 1.0 to alpha = 0.0
 */

@interface GPCrossDissolveAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

/**
 *  This property specifies whether the transition is being used for presentation or dismissal.
 *  The default value is NO, meaning it is used for presentation.
 */
@property(nonatomic, assign, getter = isDismissal) BOOL dismissal;

/**
 *  This property specifies the transition duration. The default transition duration is 0.3 seconds.
 */
@property(nonatomic, assign) NSTimeInterval duration;

/**
 *  Convenience method for creating GPCrossDissolveAnimationController objects
 *
 *  @param dimissal YES if you want to use the object for dismisal and NO for presentation.
 *
 *  @return Initialized GPCrossDissolveAnimationController object
 */
+ (GPCrossDissolveAnimationController *)animationControllerForDismissal:(BOOL)dismissal;

@end
