//
//  EHControllerInfo.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/11/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHControllerInfo : NSObject

@property(nonatomic, weak)   UIViewController *viewController;
@property(nonatomic, assign) NSUInteger        level;

+ (EHControllerInfo *)infoWithController:(UIViewController *)controller level:(NSUInteger)level;

@end
