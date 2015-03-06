//
//  EHCustomTransitionInfo.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHCustomTransitionStyle.h"

@interface EHCustomTransitionInfo : NSObject

@property(nonatomic, readonly, assign) EHCustomTransitionStyle style;
@property(nonatomic, readonly, copy) NSString *name;
@property(nonatomic, readwrite, assign) BOOL selected;

+ (EHCustomTransitionInfo *)infoWithStyle:(EHCustomTransitionStyle)style name:(NSString *)name;

@end
