//
//  EHCustomPresentationStyleInfo.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/9/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHCustomPresentationDefinitions.h"

@interface EHCustomPresentationStyleInfo : NSObject

@property(nonatomic, readonly, assign) EHCustomPresentationStyle style;
@property(nonatomic, readonly, copy)   NSString *name;
@property(nonatomic, assign) BOOL selected;

+ (EHCustomPresentationStyleInfo *)infoWithStyle:(EHCustomPresentationStyle)style name:(NSString *)name;

@end
