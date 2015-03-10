//
//  EHCustomTransitionViewController.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/8/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHCustomPresentationDefinitions.h"

@protocol EHCustomTransitionViewController <NSObject>

@required

@property(nonatomic, assign) EHCustomPresentationStyle customPresentationStyle;
@property(nonatomic, assign) EHCustomTransitionStyle   customTransitionStyle;

@end
