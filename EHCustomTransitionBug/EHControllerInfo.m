//
//  EHControllerInfo.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/11/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHControllerInfo.h"

@implementation EHControllerInfo

+ (EHControllerInfo *)infoWithController:(UIViewController *)controller level:(NSUInteger)level {
    EHControllerInfo *info = [[EHControllerInfo alloc] init];
    info.viewController = controller;
    info.level          = level;

    return info;
}

@end
