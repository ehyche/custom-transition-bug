//
//  EHViewController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/8/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHViewController.h"
#import "GPCoverVerticalAnimationController.h"
#import "GPCrossDissolveAnimationController.h"
#import "GPFadeWithBlurredBackgroundAnimationController.h"
#import "EHModalPresentationStyleInfo.h"
#import "EHModalTransitionStyleInfo.h"
#import "EHCustomTransitionStyle.h"
#import "EHCustomTransitionInfo.h"
#import "EHBooleanSwitchCell.h"
#import "EHNameValueDisplayCell.h"
#import "EHNameValueChangeCell.h"
#import "EHSelectionOption.h"
#import "EHSelectionTableViewController.h"

NSInteger const kEHSectionIndexThisController = 0;
NSInteger const kEHSectionIndexControllerToPresent = 1;

NSInteger const kEHSectionCount = 2;
NSInteger const kEHSectionThisControllerNumRows = 3;
NSInteger const kEHSectionControllerToPresentNumRows = 3;

// These are common to both sections
NSInteger const kEHRowModalPresentationStyle = 0;
NSInteger const kEHRowModalTransitionStyle = 1;
// These are rows specific to the This Controller section
NSInteger const kEHRowDefinesPresentationContext = 2;
// These are rows specific to the Controller To Present section
NSInteger const kEHRowWrapInNavigationController = 2;

CGFloat const kButtonHeight = 44.0;
CGFloat const kButtonPadding = 5.0;

NSInteger const kBooleanCellTagDefinesPresentationContext = 100;
NSInteger const kBooleanCellTagWrapInNavigationController = 101;

NSInteger const kSelectionControllerTagModalPresentationStyle = 200;
NSInteger const kSelectionControllerTagModalTransitionStyle   = 201;

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface EHViewController() <UIViewControllerTransitioningDelegate,
                               EHBooleanSwitchCellDelegate,
                               EHSelectionTableViewControllerDelegate>

@property(nonatomic, strong) UILabel *headerView;
@property(nonatomic, strong) UIButton *presentButton;
@property(nonatomic, strong) UIButton *doneButton;
@property(nonatomic, strong) UIView *footerContainerView;
@property(nonatomic, copy)   NSArray *modalPresentationStyles;
@property(nonatomic, copy)   NSArray *modalTransitionStyles;
@property(nonatomic, copy)   NSArray *customTransitionStyles;

@property(nonatomic, assign) UIModalPresentationStyle modalPresentationStyleToUse;
@property(nonatomic, assign) UIModalTransitionStyle   modalTransitionStyleToUse;
@property(nonatomic, assign) BOOL                     shouldWrapInNavigationController;

@end

@implementation EHViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.headerView = [[UILabel alloc] init];
        self.headerView.textColor = [UIColor blackColor];
        self.headerView.textAlignment = NSTextAlignmentCenter;

        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.doneButton.backgroundColor = [UIColor redColor];
        [self.doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.presentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.presentButton setTitle:@"Present" forState:UIControlStateNormal];
        [self.presentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.presentButton.backgroundColor = [UIColor greenColor];
        [self.presentButton addTarget:self action:@selector(presentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        CGFloat footerContainerViewHeight = kButtonPadding + (2.0 * kButtonHeight);
        CGRect footerViewFrame = CGRectMake(0.0, 0.0, 320.0, footerContainerViewHeight);
        self.footerContainerView = [[UIView alloc] initWithFrame:footerViewFrame];
        self.footerContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        CGRect presentButtonFrame = CGRectMake(0.0, 0.0, footerViewFrame.size.width, kButtonHeight);
        self.presentButton.frame = presentButtonFrame;
        self.presentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.footerContainerView addSubview:self.presentButton];

        CGRect doneButtonFrame = CGRectMake(0.0, kButtonHeight + kButtonPadding, footerViewFrame.size.width, kButtonHeight);
        self.doneButton.frame = doneButtonFrame;
        self.doneButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.footerContainerView addSubview:self.doneButton];

        self.modalPresentationStyles = @[[EHModalPresentationStyleInfo infoWithStyle:UIModalPresentationFullScreen name:@"UIModalPresentationFullScreen"],
                                         [EHModalPresentationStyleInfo infoWithStyle:UIModalPresentationPageSheet name:@"UIModalPresentationPageSheet"],
                                         [EHModalPresentationStyleInfo infoWithStyle:UIModalPresentationFormSheet name:@"UIModalPresentationFormSheet"],
                                         [EHModalPresentationStyleInfo infoWithStyle:UIModalPresentationCurrentContext name:@"UIModalPresentationCurrentContext"],
                                         [EHModalPresentationStyleInfo infoWithStyle:UIModalPresentationCustom name:@"UIModalPresentationCustom"],
                                         [EHModalPresentationStyleInfo infoWithStyle:UIModalPresentationOverFullScreen name:@"UIModalPresentationOverFullScreen"],
                                         [EHModalPresentationStyleInfo infoWithStyle:UIModalPresentationOverCurrentContext name:@"UIModalPresentationOverCurrentContext"],
                                         [EHModalPresentationStyleInfo infoWithStyle:UIModalPresentationPopover name:@"UIModalPresentationPopover"]
                                         ];
        self.modalTransitionStyles = @[[EHModalTransitionStyleInfo infoWithStyle:UIModalTransitionStyleCoverVertical name:@"UIModalTransitionStyleCoverVertical"],
                                       [EHModalTransitionStyleInfo infoWithStyle:UIModalTransitionStyleFlipHorizontal name:@"UIModalTransitionStyleFlipHorizontal"],
                                       [EHModalTransitionStyleInfo infoWithStyle:UIModalTransitionStyleCrossDissolve name:@"UIModalTransitionStyleCrossDissolve"],
                                       [EHModalTransitionStyleInfo infoWithStyle:UIModalTransitionStylePartialCurl name:@"UIModalTransitionStylePartialCurl"]
                                       ];
        self.customTransitionStyles = @[[EHCustomTransitionInfo infoWithStyle:EHCustomTransitionStyleNone name:@"None"],
                                        [EHCustomTransitionInfo infoWithStyle:EHCustomTransitionStyleCoverVertical name:@"Custom CoverVertical Look-alike"],
                                        [EHCustomTransitionInfo infoWithStyle:EHCustomTransitionStyleCrossDissolve name:@"Custom CrossDissolve Look-alike"],
                                        [EHCustomTransitionInfo infoWithStyle:EHCustomTransitionStyleFadeInWithDimmedBackground name:@"Custom Fade-in with Dimmed Background"]
                                        ];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[EHBooleanSwitchCell class]    forCellReuseIdentifier:[EHBooleanSwitchCell reuseID]];
    [self.tableView registerClass:[EHNameValueDisplayCell class] forCellReuseIdentifier:[EHNameValueDisplayCell reuseID]];
    [self.tableView registerClass:[EHNameValueChangeCell class]  forCellReuseIdentifier:[EHNameValueChangeCell reuseID]];

    // Init the parameters to the same as this controller
    if (self.presentingViewController != nil) {
        UIViewController *presentedViewController = self.presentingViewController.presentedViewController;
        self.modalPresentationStyleToUse = presentedViewController.modalPresentationStyle;
        self.modalTransitionStyleToUse = presentedViewController.modalTransitionStyle;

    } else {
        self.modalPresentationStyleToUse = UIModalPresentationFullScreen;
        self.modalTransitionStyleToUse = UIModalTransitionStyleCoverVertical;
    }
    self.shouldWrapInNavigationController = (self.navigationController != nil);

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.navigationController != nil) {
        self.navigationItem.title = [NSString stringWithFormat:@"Controller %@", @(self.controllerIndex)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Present"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(presentButtonTapped:)];
        if (self.controllerIndex > 0) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                   target:self
                                                                                                   action:@selector(doneButtonTapped:)];
        }
    } else {
        self.headerView.text = [NSString stringWithFormat:@"Controller %@", @(self.controllerIndex)];
        self.headerView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, kButtonHeight);
        self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        self.tableView.tableHeaderView = self.headerView;
        self.tableView.tableFooterView = self.footerContainerView;
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kEHSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 0;

    if (section == kEHSectionIndexThisController) {
        numRows = kEHSectionThisControllerNumRows;
    } else if (section == kEHSectionIndexControllerToPresent) {
        numRows = kEHSectionControllerToPresentNumRows;
    }

    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseID = nil;
    if (indexPath.section == kEHSectionIndexThisController) {
        if (indexPath.row == kEHRowDefinesPresentationContext) {
            reuseID = [EHBooleanSwitchCell reuseID];
        } else {
            reuseID = [EHNameValueDisplayCell reuseID];
        }
    } else if (indexPath.section == kEHSectionIndexControllerToPresent) {
        if (indexPath.row == kEHRowWrapInNavigationController) {
            reuseID = [EHBooleanSwitchCell reuseID];
        } else {
            reuseID = [EHNameValueChangeCell reuseID];
        }
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];

    NSString *text = nil;
    NSString *detailText = nil;
    BOOL cellOn = NO;
    NSInteger booleanCellTag = 0;
    if (indexPath.section == kEHSectionIndexThisController) {
        if (indexPath.row == kEHRowModalPresentationStyle) {
            text = @"UIModalPresentationStyle";
            detailText = [self ourModalPresentationStyle];
        } else if (indexPath.row == kEHRowModalTransitionStyle) {
            text = @"UIModalTransitionStyle";
            detailText = [self ourModalTransitionStyle];
        } else if (indexPath.row == kEHRowDefinesPresentationContext) {
            text = @"Defines Presentation Context";
            cellOn = self.definesPresentationContext;
            booleanCellTag = kBooleanCellTagDefinesPresentationContext;
        }
    } else if (indexPath.section == kEHSectionIndexControllerToPresent) {
        if (indexPath.row == kEHRowModalPresentationStyle) {
            text = @"UIModalPresentationStyle";
            detailText = [self stringForModalPresentationStyle:self.modalPresentationStyleToUse];
        } else if (indexPath.row == kEHRowModalTransitionStyle) {
            text = @"UIModalTransitionStyle";
            detailText = [self stringForModalTransitionStyle:self.modalTransitionStyleToUse];
        } else if (indexPath.row == kEHRowWrapInNavigationController) {
            text = @"Wrap in UINavigationController";
            cellOn = YES;
            booleanCellTag = kBooleanCellTagWrapInNavigationController;
        }
    }

    cell.textLabel.text = text;
    if (detailText.length > 0) {
        cell.detailTextLabel.text = detailText;
    }

    if ([cell isKindOfClass:[EHBooleanSwitchCell class]]) {
        EHBooleanSwitchCell *switchCell = (EHBooleanSwitchCell *)cell;
        switchCell.on = cellOn;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;

    if (section == kEHSectionIndexThisController) {
        title = @"This View Controller";
    } else if (section == kEHSectionIndexControllerToPresent) {
        title = @"View Controller to Present";
    }

    return title;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == kEHSectionIndexControllerToPresent) {
        if (indexPath.item == kEHRowModalPresentationStyle) {
            // Let the user choose a modal presentation style
            [self showModalPresentationStylesSelectionController];
        } else if (indexPath.item == kEHRowModalTransitionStyle) {
            // Let the user choose a modal transition style
            [self showModalTransitionStylesSelectionController];
        }
    }
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    id<UIViewControllerAnimatedTransitioning> animator = nil;

    //    EHCustomTransitionStyle style = [self selectedCustomTransitionStyle];
    //
    //    if (style == EHCustomTransitionStyleCoverVertical) {
    //        GPCoverVerticalAnimationController *coverVertical = [[GPCoverVerticalAnimationController alloc] init];
    //        coverVertical.dismissal = NO;
    //        animator = coverVertical;
    //    } else if (style == EHCustomTransitionStyleCrossDissolve) {
    //        GPCrossDissolveAnimationController *crossDissolve = [[GPCrossDissolveAnimationController alloc] init];
    //        crossDissolve.dismissal = NO;
    //        animator = crossDissolve;
    //    } else if (style == EHCustomTransitionStyleFadeInWithDimmedBackground) {
    //        GPFadeWithBlurredBackgroundAnimationController *fade = [[GPFadeWithBlurredBackgroundAnimationController alloc] init];
    //        fade.dismissal = NO;
    //        animator = fade;
    //    }

    return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    id<UIViewControllerAnimatedTransitioning> animator = nil;

    //    EHCustomTransitionStyle style = [self selectedCustomTransitionStyle];
    //
    //    if (style == EHCustomTransitionStyleCoverVertical) {
    //        GPCoverVerticalAnimationController *coverVertical = [[GPCoverVerticalAnimationController alloc] init];
    //        coverVertical.dismissal = YES;
    //        animator = coverVertical;
    //    } else if (style == EHCustomTransitionStyleCrossDissolve) {
    //        GPCrossDissolveAnimationController *crossDissolve = [[GPCrossDissolveAnimationController alloc] init];
    //        crossDissolve.dismissal = YES;
    //        animator = crossDissolve;
    //    } else if (style == EHCustomTransitionStyleFadeInWithDimmedBackground) {
    //        GPFadeWithBlurredBackgroundAnimationController *fade = [[GPFadeWithBlurredBackgroundAnimationController alloc] init];
    //        fade.dismissal = YES;
    //        animator = fade;
    //    }

    return animator;
}

#pragma mark - EHBooleanSwitchCellDelegate methods

- (void)booleanSwitchCellValueChanged:(EHBooleanSwitchCell *)cell {
    if (cell.tag == kBooleanCellTagDefinesPresentationContext) {
        self.definesPresentationContext = cell.isOn;
    } else if (cell.tag == kBooleanCellTagWrapInNavigationController) {
        self.shouldWrapInNavigationController = cell.isOn;
    }
}

#pragma mark - EHSelectionTableViewControllerDelegate methods

- (void)selectionTableViewControllerDidChangeSelection:(EHSelectionTableViewController *)controller {
    // Get the selected option (there should be only one)
    NSArray *selectedOptions = [controller.selectionOptions objectsAtIndexes:controller.selectedIndexes];
    EHSelectionOption *selectedOption = nil;
    if (selectedOptions.count > 0) {
        selectedOption = selectedOptions[0];
    }

    if (controller.tag == kSelectionControllerTagModalPresentationStyle) {
        UIModalPresentationStyle styleData = [selectedOption.data integerValue];
        self.modalPresentationStyleToUse = styleData;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    } else if (controller.tag == kSelectionControllerTagModalTransitionStyle) {
        UIModalTransitionStyle styleData = [selectedOption.data integerValue];
        self.modalTransitionStyleToUse = styleData;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - EHViewController private methods

- (void)presentButtonTapped:(id)sender {
    // Present another color controller, but this time full-screen
    EHViewController *controller = [[EHViewController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.controllerIndex = self.controllerIndex + 1;

    UIViewController *controllerToPresent = controller;
    if (self.shouldWrapInNavigationController) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        controllerToPresent = navController;
    }

    controllerToPresent.modalPresentationStyle = self.modalPresentationStyleToUse;
    controllerToPresent.modalTransitionStyle   = self.modalTransitionStyleToUse;

    [self presentViewController:controllerToPresent animated:YES completion:^{
        NSLog(@"Presentation of controller completion block");
    }];
}

- (void)doneButtonTapped:(id)sender {
    if (self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)stringForModalPresentationStyle:(UIModalPresentationStyle)style {
    NSString *str = @"Unknown";

    for (EHModalPresentationStyleInfo *info in self.modalPresentationStyles) {
        if (info.style == style) {
            str = info.name;
            break;
        }
    }

    return str;
}

- (NSString *)stringForModalTransitionStyle:(UIModalTransitionStyle)style {
    NSString *str = @"Unknown";

    for (EHModalTransitionStyleInfo *info in self.modalTransitionStyles) {
        if (info.style == style) {
            str = info.name;
            break;
        }
    }

    return str;
}

- (NSString *)stringForCustomTransitionStyle:(EHCustomTransitionStyle)style {
    NSString *str = @"Unknown";

    for (EHCustomTransitionInfo *info in self.customTransitionStyles) {
        if (info.style == style) {
            str = info.name;
            break;
        }
    }

    return str;
}

- (NSString *)ourModalPresentationStyle {
    NSString *style = @"Not Presented";

    if (self.presentingViewController != nil) {
        UIViewController *presentedViewController = self.presentingViewController.presentedViewController;
        style = [self stringForModalPresentationStyle:presentedViewController.modalPresentationStyle];
    }

    return style;
}

- (NSString *)ourModalTransitionStyle {
    NSString *style = @"Not Presented";

    if (self.presentingViewController != nil) {
        UIViewController *presentedViewController = self.presentingViewController.presentedViewController;
        style = [self stringForModalTransitionStyle:presentedViewController.modalTransitionStyle];
    }

    return style;
}

- (NSArray *)selectionOptionsFromModalPresentationStyles {
    BOOL isPreIOS8 = SYSTEM_VERSION_LESS_THAN(@"8.0");
    NSUInteger numOptions = (isPreIOS8 ? 5 : self.modalPresentationStyles.count);

    NSMutableArray *tmpOptions = [NSMutableArray arrayWithCapacity:numOptions];
    for (NSUInteger i = 0; i < numOptions; i++) {
        EHModalPresentationStyleInfo *ithInfo = self.modalPresentationStyles[i];
        EHSelectionOption *ithOption = [[EHSelectionOption alloc] init];
        ithOption.text = ithInfo.name;
        ithOption.selected = (ithInfo.style == self.modalPresentationStyleToUse);
        ithOption.data = @(ithInfo.style);
        [tmpOptions addObject:ithOption];
    }

    return [NSArray arrayWithArray:tmpOptions];
}

- (NSArray *)selectionOptionsFromModalTransitionStyles {
    NSUInteger numOptions = self.modalTransitionStyles.count;
    NSMutableArray *tmpOptions = [NSMutableArray arrayWithCapacity:numOptions];
    for (NSUInteger i = 0; i < numOptions; i++) {
        EHModalTransitionStyleInfo *ithInfo = self.modalTransitionStyles[i];
        EHSelectionOption *ithOption = [[EHSelectionOption alloc] init];
        ithOption.text = ithInfo.name;
        ithOption.selected = (ithInfo.style == self.modalTransitionStyleToUse);
        ithOption.data = @(ithInfo.style);
        [tmpOptions addObject:ithOption];
    }

    return [NSArray arrayWithArray:tmpOptions];
}

- (void)showModalPresentationStylesSelectionController {
    EHSelectionTableViewController *controller = [[EHSelectionTableViewController alloc] initWithTitle:@"UIModalPresentationStyle"
                                                                                          sectionTitle:nil
                                                                                      selectionOptions:[self selectionOptionsFromModalPresentationStyles]
                                                                                     canSelectMultiple:NO];
    controller.tag = kSelectionControllerTagModalPresentationStyle;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showModalTransitionStylesSelectionController {
    EHSelectionTableViewController *controller = [[EHSelectionTableViewController alloc] initWithTitle:@"UIModalTransitionStyle"
                                                                                          sectionTitle:nil
                                                                                      selectionOptions:[self selectionOptionsFromModalTransitionStyles]
                                                                                     canSelectMultiple:NO];
    controller.tag = kSelectionControllerTagModalTransitionStyle;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
