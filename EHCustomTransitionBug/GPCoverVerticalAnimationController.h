//
//  GPCoverVerticalAnimationController.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This animation controller:
 *
 *  - Is a custom transition lookalike for .modalTransitionStyle = UIModalTransitionStyleCoverVertical
 *  - On presentation, it slides up the presented controller from the bottom
 *  - On dismissal, it slides down the presented controller from the top
 */

@interface GPCoverVerticalAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

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
 *  Convenience method for creating GPCoverVerticalAnimationController objects
 *
 *  @param dimissal YES if you want to use the object for dismisal and NO for presentation.
 *
 *  @return Initialized GPCoverVerticalAnimationController object
 */
+ (GPCoverVerticalAnimationController *)animationControllerForDismissal:(BOOL)dismissal;

@end
