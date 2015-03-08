//
//  EHSelectionTableViewController.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EHSelectionTableViewController;

@protocol EHSelectionTableViewControllerDelegate <NSObject>

@required

- (void)selectionTableViewControllerDidChangeSelection:(EHSelectionTableViewController *)controller;

@end

@interface EHSelectionTableViewController : UITableViewController

@property(nonatomic, assign) NSInteger tag;

@property(nonatomic, readonly, copy) NSIndexSet *selectedIndexes;
@property(nonatomic, readonly, copy) NSArray    *selectionOptions;

@property(nonatomic, weak) id<EHSelectionTableViewControllerDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title
                 sectionTitle:(NSString *)sectionTitle
             selectionOptions:(NSArray *)selectionOptions
            canSelectMultiple:(BOOL)canSelectMultiple;

@end
