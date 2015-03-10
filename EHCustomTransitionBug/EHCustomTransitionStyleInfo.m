//
//  EHCustomTransitionInfo.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHCustomTransitionStyleInfo.h"

@interface EHCustomTransitionStyleInfo()

@property(nonatomic, readwrite, assign) EHCustomTransitionStyle style;
@property(nonatomic, readwrite, copy) NSString *name;

@end

@implementation EHCustomTransitionStyleInfo

+ (EHCustomTransitionStyleInfo *)infoWithStyle:(EHCustomTransitionStyle)style name:(NSString *)name {
    EHCustomTransitionStyleInfo *info = [[EHCustomTransitionStyleInfo alloc] init];
    info.style = style;
    info.name = name;
    return info;
}

@end
