//
//  EHControllerCounter.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/12/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHControllerCounter.h"

@interface EHControllerCounter()

@property(nonatomic, readwrite, assign) NSUInteger controllerIndex;

@end

@implementation EHControllerCounter

+ (EHControllerCounter *)sharedInstance {
    static EHControllerCounter *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[EHControllerCounter alloc] init];
    });
    return sInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _controllerIndex = 0;
    }

    return self;
}

- (NSUInteger)controllerIndexWithPostIncrement {
    NSUInteger index = self.controllerIndex;
    self.controllerIndex += 1;
    return index;
}

- (void)decrementControllerIndex {
    self.controllerIndex = (self.controllerIndex > 0 ? self.controllerIndex - 1 : 0);
}

@end
