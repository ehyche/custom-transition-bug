//
//  EHModalPresentationStyleInfo.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHModalPresentationStyleInfo : NSObject

@property(nonatomic, readonly, assign) UIModalPresentationStyle style;
@property(nonatomic, readonly, copy)   NSString *name;
@property(nonatomic, assign) BOOL selected;

+ (EHModalPresentationStyleInfo *)infoWithStyle:(UIModalPresentationStyle)style name:(NSString *)name;

@end
