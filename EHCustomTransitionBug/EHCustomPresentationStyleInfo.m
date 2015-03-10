//
//  EHCustomPresentationStyleInfo.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/9/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHCustomPresentationStyleInfo.h"

@interface EHCustomPresentationStyleInfo()

@property(nonatomic, readwrite, assign) EHCustomPresentationStyle style;
@property(nonatomic, readwrite, copy) NSString *name;

@end

@implementation EHCustomPresentationStyleInfo

+ (EHCustomPresentationStyleInfo *)infoWithStyle:(EHCustomPresentationStyle)style name:(NSString *)name {
    EHCustomPresentationStyleInfo *info = [[EHCustomPresentationStyleInfo alloc] init];
    info.style = style;
    info.name = name;
    return info;
}

@end
