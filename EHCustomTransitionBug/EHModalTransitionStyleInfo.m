//
//  EHModalTransitionStyleInfo.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHModalTransitionStyleInfo.h"

@interface EHModalTransitionStyleInfo()

@property(nonatomic, readwrite, assign) UIModalTransitionStyle style;
@property(nonatomic, readwrite, copy)   NSString               *name;

@end

@implementation EHModalTransitionStyleInfo

+ (EHModalTransitionStyleInfo *)infoWithStyle:(UIModalTransitionStyle)style name:(NSString *)name {
    EHModalTransitionStyleInfo *info = [[EHModalTransitionStyleInfo alloc] init];
    info.style = style;
    info.name = name;
    return info;
}

@end
