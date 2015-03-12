//
//  EHFullScreenPresentationController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/9/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHFullScreenPresentationController.h"
#import "EHCustomPresentationDefinitions.h"

@implementation EHFullScreenPresentationController

#pragma mark - EHPresentationController methods

+ (EHCustomPresentationStyle)customPresentationStyle {
    return EHCustomPresentationStyleFullScreen;
}

+ (CGSize)defaultPresentedSizeForViewController:(UIViewController *)controller {
    UIScreen *mainScreen = [UIScreen mainScreen];
    return mainScreen.bounds.size;
}

@end
