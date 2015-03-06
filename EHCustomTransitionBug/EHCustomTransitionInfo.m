//
//  EHCustomTransitionInfo.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHCustomTransitionInfo.h"

@interface EHCustomTransitionInfo()

@property(nonatomic, readwrite, assign) EHCustomTransitionStyle style;
@property(nonatomic, readwrite, copy) NSString *name;

@end

@implementation EHCustomTransitionInfo

+ (EHCustomTransitionInfo *)infoWithStyle:(EHCustomTransitionStyle)style name:(NSString *)name {
    EHCustomTransitionInfo *info = [[EHCustomTransitionInfo alloc] init];
    info.style = style;
    info.name = name;
    return info;
}

@end
