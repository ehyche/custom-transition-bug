//
//  EHSelectionTableViewController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHSelectionTableViewController.h"

@implementation EHSelectionTableViewController

- (instancetype)initWithTitle:(NSString *)title
                 sectionTitle:(NSString *)sectionTitle
             selectionOptions:(NSArray *)selectionOptions
            canSelectMultiple:(BOOL)canSelectMultiple {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }

    return self;
}

@end
