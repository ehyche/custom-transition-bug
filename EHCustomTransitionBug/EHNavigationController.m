//
//  EHNavigationController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/8/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHNavigationController.h"
#import "EHControllerCounter.h"

@interface EHNavigationController()

@property(nonatomic, assign) NSUInteger controllerIndex;

@end

@implementation EHNavigationController

@synthesize customPresentationStyle;
@synthesize customTransitionStyle;

- (void)dealloc {
    [[EHControllerCounter sharedInstance] decrementControllerIndex];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        _controllerIndex = [[EHControllerCounter sharedInstance] controllerIndexWithPostIncrement];
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Navigation %@", @(self.controllerIndex)];
}

@end
