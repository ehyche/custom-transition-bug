//
//  EHModalTransitionStyleInfo.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHModalTransitionStyleInfo : NSObject

@property(nonatomic, readonly, assign) UIModalTransitionStyle style;
@property(nonatomic, readonly, copy)   NSString               *name;
@property(nonatomic, assign) BOOL selected;

+ (EHModalTransitionStyleInfo *)infoWithStyle:(UIModalTransitionStyle)style name:(NSString *)name;

@end
