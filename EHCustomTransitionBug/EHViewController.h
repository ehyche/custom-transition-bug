//
//  EHViewController.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/8/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHCustomTransitionStyle.h"

@interface EHViewController : UITableViewController

@property(nonatomic, assign) NSUInteger controllerIndex;
@property(nonatomic, assign) EHCustomTransitionStyle customTransitionStyle;

@end
