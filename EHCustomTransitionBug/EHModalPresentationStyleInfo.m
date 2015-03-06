//
//  EHModalPresentationStyleInfo.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHModalPresentationStyleInfo.h"

@interface EHModalPresentationStyleInfo()

@property(nonatomic, readwrite, assign) UIModalPresentationStyle style;
@property(nonatomic, readwrite, copy)   NSString *name;

@end

@implementation EHModalPresentationStyleInfo

+ (EHModalPresentationStyleInfo *)infoWithStyle:(UIModalPresentationStyle)style name:(NSString *)name {
    EHModalPresentationStyleInfo *info = [[EHModalPresentationStyleInfo alloc] init];
    info.style = style;
    info.name = name;
    return info;
}

@end
