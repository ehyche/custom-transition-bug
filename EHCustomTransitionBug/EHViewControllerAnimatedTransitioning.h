//
//  EHViewControllerAnimatedTransitioning.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/9/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHCustomPresentationDefinitions.h"

@protocol EHViewControllerAnimatedTransitioning <UIViewControllerAnimatedTransitioning>

@required

+ (EHCustomTransitionStyle)customTransitionStyle;

@property(nonatomic, assign, getter=isPresenting) BOOL presenting;

@property(nonatomic, assign) NSTimeInterval duration;

@end
