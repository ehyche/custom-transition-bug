//
//  EHControllerCounter.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/12/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHControllerCounter : NSObject

- (NSUInteger)controllerIndexWithPostIncrement;
- (void)decrementControllerIndex;

+ (EHControllerCounter *)sharedInstance;

@end
