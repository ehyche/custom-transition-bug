//
//  EHViewController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/8/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHViewController.h"
#import "EHModalPresentationStyleInfo.h"
#import "EHModalTransitionStyleInfo.h"
#import "EHCustomPresentationDefinitions.h"
#import "EHCustomTransitionStyleInfo.h"
#import "EHCustomPresentationStyleInfo.h"
#import "EHBooleanSwitchCell.h"
#import "EHNameValueDisplayCell.h"
#import "EHNameValueChangeCell.h"
#import "EHStepperCell.h"
#import "EHSelectionOption.h"
#import "EHSelectionTableViewController.h"
#import "EHNavigationController.h"
#import "EHUtilities.h"
#import "EHViewControllerAnimatedTransitioning.h"
#import "EHControllerInfo.h"
#import "EHControllerCounter.h"
// Presentation controllers
#import "EHDimPresentationController.h"
#import "EHBlurPresentationController.h"
#import "EHFullScreenPresentationController.h"
// Animation controllers
#import "EHCoverVerticalAnimationController.h"
#import "EHCrossDissolveAnimationController.h"
#import "EHZoomInAnimationController.h"

NSInteger const kEHSectionIndexThisController = 0;
NSInteger const kEHSectionIndexControllerToPresent = 1;
NSInteger const kEHSectionIndexPresentedController = 2;
NSInteger const kEHSectionIndexPresentingController = 3;

NSInteger const kEHSectionCount = 4;
NSInteger const kEHSectionThisControllerNumRows = 7;
NSInteger const kEHSectionControllerToPresentNumRows = 7;

// These are common to both sections
NSInteger const kEHRowModalPresentationStyle = 0;
NSInteger const kEHRowModalTransitionStyle = 1;
NSInteger const kEHRowCustomPresentationStyle = 2;
NSInteger const kEHRowCustomTransitionStyle = 3;
NSInteger const kEHRowPreferredContentSizeWidth = 4;
NSInteger const kEHRowPreferredContentSizeHeight = 5;
// These are rows specific to the This Controller section
NSInteger const kEHRowDefinesPresentationContext = 6;
// These are rows specific to the Controller To Present section
NSInteger const kEHRowWrapInNavigationController = 6;

CGFloat const kButtonHeight = 44.0;
CGFloat const kButtonPadding = 5.0;

NSInteger const kBooleanCellTagDefinesPresentationContext = 100;
NSInteger const kBooleanCellTagWrapInNavigationController = 101;

NSInteger const kStepperCellTagPreferredContentSizeWidth  = 300;
NSInteger const kStepperCellTagPreferredContentSizeHeight = 301;

NSInteger const kSelectionControllerTagModalPresentationStyle  = 200;
NSInteger const kSelectionControllerTagModalTransitionStyle    = 201;
NSInteger const kSelectionControllerTagCustomPresentationStyle = 202;
NSInteger const kSelectionControllerTagCustomTransitionStyle   = 203;

CGFloat const kPreferredContentWidthDefaultFormSheet = 540.0;
CGFloat const kPreferredContentHeightDefaultFormSheet = 620.0;

static NSString * const kEHModalPresentationStyleString     = @"UIModalPresentationStyle";
static NSString * const kEHModalTransitionStyleString       = @"UIModalTransitionStyle";
static NSString * const kEHCustomPresentationStyleString    = @"Custom Presentation Style";
static NSString * const kEHCustomTransitionStyleString      = @"Custom Transition Style";
static NSString * const kEHPreferredContentSizeWidthString  = @"Preferred Content Size Width";
static NSString * const kEHPreferredContentSizeHeightString = @"Preferred Content Size Height";

@interface EHViewController() <UIViewControllerTransitioningDelegate,
                               EHBooleanSwitchCellDelegate,
                               EHStepperCellDelegate,
                               EHSelectionTableViewControllerDelegate>

@property(nonatomic, assign) NSUInteger controllerIndex;
@property(nonatomic, strong) UILabel *headerView;
@property(nonatomic, strong) UIButton *presentButton;
@property(nonatomic, strong) UIButton *pushButton;
@property(nonatomic, strong) UIButton *doneButton;
@property(nonatomic, strong) UIView *buttonContainerView;
@property(nonatomic, copy)   NSArray *modalPresentationStyles;
@property(nonatomic, copy)   NSArray *modalTransitionStyles;
@property(nonatomic, copy)   NSArray *customPresentationStyles;
@property(nonatomic, copy)   NSArray *customTransitionStyles;

@property(nonatomic, assign) UIModalPresentationStyle  modalPresentationStyleToUse;
@property(nonatomic, assign) UIModalTransitionStyle    modalTransitionStyleToUse;
@property(nonatomic, assign) EHCustomPresentationStyle customPresentationStyleToUse;
@property(nonatomic, assign) EHCustomTransitionStyle   customTransitionStyleToUse;
@property(nonatomic, assign) BOOL                      shouldWrapInNavigationController;
@property(nonatomic, assign) CGSize                    preferredContentSizeToUse;

@property(nonatomic, strong) NSArray *controllerInfo;

@end

@implementation EHViewController

@synthesize customPresentationStyle;
@synthesize customTransitionStyle;

- (void)dealloc {
    [[EHControllerCounter sharedInstance] decrementControllerIndex];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _controllerIndex = [[EHControllerCounter sharedInstance] controllerIndexWithPostIncrement];

        self.headerView = [[UILabel alloc] init];
        self.headerView.textColor = [UIColor blackColor];
        self.headerView.textAlignment = NSTextAlignmentCenter;

        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.presentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.presentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.presentButton setTitle:@"Present" forState:UIControlStateNormal];
        [self.presentButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.presentButton addTarget:self action:@selector(presentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.pushButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.pushButton setTitle:@"Push" forState:UIControlStateNormal];
        [self.pushButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.pushButton addTarget:self action:@selector(pushButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        CGRect buttonContainerFrame = CGRectMake(0.0, 0.0, 320.0, kButtonHeight);
        self.buttonContainerView = [[UIView alloc] initWithFrame:buttonContainerFrame];
        self.buttonContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [self.buttonContainerView addSubview:self.presentButton];
        [self.buttonContainerView addSubview:self.pushButton];
        [self.buttonContainerView addSubview:self.doneButton];

        // Add constraints
        NSDictionary *views = @{@"present" : self.presentButton,
                                @"push"    : self.pushButton,
                                @"done"    : self.doneButton};
        [self.buttonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[present]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:views]];
        [self.buttonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[push]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:views]];
        [self.buttonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[done]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:views]];
        // Then layout the buttons left to right with equal width
        [self.buttonContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[present][push(==present)][done(==present)]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:views]];

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
        self.customTransitionStyles = @[[EHCustomTransitionStyleInfo infoWithStyle:EHCustomTransitionStyleCoverVertical name:@"Slide Up From Bottom"],
                                        [EHCustomTransitionStyleInfo infoWithStyle:EHCustomTransitionStyleCrossDissolve name:@"Fade In"],
                                        [EHCustomTransitionStyleInfo infoWithStyle:EHCustomTransitionStyleZoomInWithBounce name:@"Zoom In"]
                                       ];
        self.customPresentationStyles = @[[EHCustomPresentationStyleInfo infoWithStyle:EHCustomPresentationStyleFullScreen name:@"Full Screen"],
                                          [EHCustomPresentationStyleInfo infoWithStyle:EHCustomPresentationStyleCustomSizeDimmedBackground name:@"Custom Size With Dimmed Background"],
                                          [EHCustomPresentationStyleInfo infoWithStyle:EHCustomPresentationStyleCustomSizeBlurredBackground name:@"Custom Size With Blurred Background"]
                                         ];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[EHBooleanSwitchCell class]    forCellReuseIdentifier:[EHBooleanSwitchCell reuseID]];
    [self.tableView registerClass:[EHStepperCell class]          forCellReuseIdentifier:[EHStepperCell reuseID]];
    [self.tableView registerClass:[EHNameValueDisplayCell class] forCellReuseIdentifier:[EHNameValueDisplayCell reuseID]];
    [self.tableView registerClass:[EHNameValueChangeCell class]  forCellReuseIdentifier:[EHNameValueChangeCell reuseID]];

    // Init the parameters to the same as this controller
    if (self.presentingViewController != nil) {
        UIViewController *presentedViewController = self.presentingViewController.presentedViewController;
        self.modalPresentationStyleToUse = presentedViewController.modalPresentationStyle;
        self.modalTransitionStyleToUse = presentedViewController.modalTransitionStyle;
        self.customPresentationStyleToUse = [self customPresentationStyleForViewController:presentedViewController];
        self.customTransitionStyleToUse = [self customTransitionStyleForViewController:presentedViewController];
    } else {
        self.modalPresentationStyleToUse = UIModalPresentationFullScreen;
        self.modalTransitionStyleToUse = UIModalTransitionStyleCoverVertical;
        self.customPresentationStyleToUse = EHCustomPresentationStyleFullScreen;
        self.customTransitionStyleToUse = EHCustomTransitionStyleCoverVertical;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.shouldWrapInNavigationController = (self.navigationController != nil);
    self.preferredContentSizeToUse        = [self ourPreferredContentSize];

    if (self.navigationController != nil) {
        // Set the title
        self.navigationItem.title = [NSString stringWithFormat:@"Controller %@", @(self.controllerIndex)];
        // Set the left bar button items
        UIBarButtonItem *presentBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Present"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(presentButtonTapped:)];
        UIBarButtonItem *pushBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Push"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pushButtonTapped:)];
        self.navigationItem.leftItemsSupplementBackButton = YES;
        self.navigationItem.leftBarButtonItems = @[presentBarButtonItem, pushBarButtonItem];
        // Add a Done button if necessary
        if (self.presentingViewController != nil) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                   target:self
                                                                                                   action:@selector(doneButtonTapped:)];
        }
    } else {
        self.headerView.text = [NSString stringWithFormat:@"Controller %@", @(self.controllerIndex)];
        self.headerView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, kButtonHeight);
        self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        self.tableView.tableHeaderView = self.headerView;
        self.tableView.tableFooterView = self.buttonContainerView;
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.controllerInfo = [EHViewController viewControllerInfo];
    [self.tableView reloadData];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Controller %@", @(self.controllerIndex)];
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
    } else if (section == kEHSectionIndexPresentedController ||
               section == kEHSectionIndexPresentingController) {
        numRows = self.controllerInfo.count;
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
        } else if (indexPath.row == kEHRowPreferredContentSizeWidth ||
                   indexPath.row == kEHRowPreferredContentSizeHeight) {
            reuseID = [EHStepperCell reuseID];
        } else {
            reuseID = [EHNameValueChangeCell reuseID];
        }
    } else if (indexPath.section == kEHSectionIndexPresentedController ||
               indexPath.section == kEHSectionIndexPresentingController) {
        reuseID = [EHNameValueDisplayCell reuseID];
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];

    NSString *text = nil;
    NSString *detailText = nil;
    BOOL cellOn = NO;
    NSInteger booleanCellTag = 0;
    CGFloat stepperValue = 0.0;
    NSInteger stepperCellTag = 0;
    NSUInteger indentLevel = 0;
    if (indexPath.section == kEHSectionIndexThisController) {
        if (indexPath.row == kEHRowModalPresentationStyle) {
            text = kEHModalPresentationStyleString;
            detailText = [self ourModalPresentationStyle];
        } else if (indexPath.row == kEHRowModalTransitionStyle) {
            text = kEHModalTransitionStyleString;
            detailText = [self ourModalTransitionStyle];
        } else if (indexPath.row == kEHRowCustomPresentationStyle) {
            text = kEHCustomPresentationStyleString;
            detailText = [self ourCustomPresentationStyle];
        } else if (indexPath.row == kEHRowCustomTransitionStyle) {
            text = kEHCustomTransitionStyleString;
            detailText = [self ourCustomTransitionStyle];
        } else if (indexPath.row == kEHRowPreferredContentSizeWidth) {
            text = kEHPreferredContentSizeWidthString;
            CGSize size = [self ourPreferredContentSize];
            detailText = [@(size.width) stringValue];
        } else if (indexPath.row == kEHRowPreferredContentSizeHeight) {
            text = kEHPreferredContentSizeHeightString;
            CGSize size = [self ourPreferredContentSize];
            detailText = [@(size.height) stringValue];
        } else if (indexPath.row == kEHRowDefinesPresentationContext) {
            text = @"Defines Presentation Context";
            cellOn = self.definesPresentationContext;
            booleanCellTag = kBooleanCellTagDefinesPresentationContext;
        }
    } else if (indexPath.section == kEHSectionIndexControllerToPresent) {
        if (indexPath.row == kEHRowModalPresentationStyle) {
            text = kEHModalPresentationStyleString;
            detailText = [self stringForModalPresentationStyle:self.modalPresentationStyleToUse];
        } else if (indexPath.row == kEHRowModalTransitionStyle) {
            text = kEHModalTransitionStyleString;
            detailText = [self stringForModalTransitionStyle:self.modalTransitionStyleToUse];
        } else if (indexPath.row == kEHRowCustomPresentationStyle) {
            text = kEHCustomPresentationStyleString;
            detailText = [self stringForCustomPresentationStyle:self.customPresentationStyleToUse];
        } else if (indexPath.row == kEHRowCustomTransitionStyle) {
            text = kEHCustomTransitionStyleString;
            detailText = [self stringForCustomTransitionStyle:self.customTransitionStyleToUse];
        } else if (indexPath.row == kEHRowPreferredContentSizeWidth) {
            text = kEHPreferredContentSizeWidthString;
            stepperValue = self.preferredContentSizeToUse.width;
            stepperCellTag = kStepperCellTagPreferredContentSizeWidth;
            detailText = [@(stepperValue) stringValue];
        } else if (indexPath.row == kEHRowPreferredContentSizeHeight) {
            text = kEHPreferredContentSizeHeightString;
            stepperValue = self.preferredContentSizeToUse.height;
            stepperCellTag = kStepperCellTagPreferredContentSizeHeight;
            detailText = [@(stepperValue) stringValue];
        } else if (indexPath.row == kEHRowWrapInNavigationController) {
            text = @"Wrap in UINavigationController";
            cellOn = YES;
            booleanCellTag = kBooleanCellTagWrapInNavigationController;
        }
    } else if (indexPath.section == kEHSectionIndexPresentedController) {
        EHControllerInfo *info = self.controllerInfo[indexPath.row];
        text = info.viewController.description;
        UIViewController *presented = info.viewController.presentedViewController;
        detailText = (presented != nil ? presented.description : @"Not Presenting");
        indentLevel = info.level;
    } else if (indexPath.section == kEHSectionIndexPresentingController) {
        EHControllerInfo *info = self.controllerInfo[indexPath.row];
        text = info.viewController.description;
        UIViewController *presenting = info.viewController.presentingViewController;
        detailText = (presenting ? presenting.description : @"Not Presented");
        indentLevel = info.level;
    }

    cell.textLabel.text = text;
    if (detailText.length > 0) {
        cell.detailTextLabel.text = detailText;
    }
    cell.indentationLevel = indentLevel;

    if ([cell isKindOfClass:[EHBooleanSwitchCell class]]) {
        EHBooleanSwitchCell *switchCell = (EHBooleanSwitchCell *)cell;
        switchCell.on = cellOn;
        switchCell.tag = booleanCellTag;
        switchCell.delegate = self;
    }

    if ([cell isKindOfClass:[EHStepperCell class]]) {
        EHStepperCell *stepperCell = (EHStepperCell *)cell;
        stepperCell.value = stepperValue;
        stepperCell.delegate = self;
        stepperCell.tag = stepperCellTag;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;

    if (section == kEHSectionIndexThisController) {
        title = @"This View Controller";
    } else if (section == kEHSectionIndexControllerToPresent) {
        title = @"View Controller to Present";
    } else if (section == kEHSectionIndexPresentedController) {
        title = @"Presented Controller";
    } else if (section == kEHSectionIndexPresentingController) {
        title = @"Presenting Controller";
    }

    return title;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == kEHSectionIndexControllerToPresent) {
        if (indexPath.row == kEHRowModalPresentationStyle) {
            // Let the user choose a modal presentation style
            [self showModalPresentationStylesSelectionController];
        } else if (indexPath.row == kEHRowModalTransitionStyle) {
            // Let the user choose a modal transition style
            [self showModalTransitionStylesSelectionController];
        } else if (indexPath.row == kEHRowCustomPresentationStyle) {
            // Let the user choose a custom presentation style
            [self showCustomPresentationStylesSelectionController];
        } else if (indexPath.row == kEHRowCustomTransitionStyle) {
            // Let the user choose the custom transition style
            [self showCustomTransitionStyleSelectionController];
        }
    }
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    EHCustomTransitionStyle style = [self customTransitionStyleForViewController:presented];
    id<EHViewControllerAnimatedTransitioning>animator = [EHViewController animatorForCustomTransitionStyle:style];
    animator.presenting = YES;

    return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    EHCustomTransitionStyle style = [self customTransitionStyleForViewController:dismissed];
    id<EHViewControllerAnimatedTransitioning>animator = [EHViewController animatorForCustomTransitionStyle:style];
    animator.presenting = NO;

    return animator;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    UIPresentationController *controller = nil;

    EHCustomPresentationStyle style = [self customPresentationStyleForViewController:presented];

    if (style == EHCustomPresentationStyleFullScreen) {
        controller = [[EHFullScreenPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    } else if (style == EHCustomPresentationStyleCustomSizeDimmedBackground) {
        controller = [[EHDimPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    } else if (style == EHCustomPresentationStyleCustomSizeBlurredBackground) {
        controller = [[EHBlurPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    }

    return controller;
}


#pragma mark - EHBooleanSwitchCellDelegate methods

- (void)booleanSwitchCellValueChanged:(EHBooleanSwitchCell *)cell {
    if (cell.tag == kBooleanCellTagDefinesPresentationContext) {
        self.definesPresentationContext = cell.isOn;
    } else if (cell.tag == kBooleanCellTagWrapInNavigationController) {
        self.shouldWrapInNavigationController = cell.isOn;
    }
}

#pragma mark - EHStepperCellDelegate methods

- (void)stepperCellValueDidChange:(EHStepperCell *)cell {
    if (cell.tag == kStepperCellTagPreferredContentSizeWidth) {
        self.preferredContentSizeToUse = CGSizeMake(cell.value, self.preferredContentSizeToUse.height);
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kEHRowPreferredContentSizeWidth inSection:kEHSectionIndexControllerToPresent]]
                              withRowAnimation:UITableViewRowAnimationNone];
    } else if (cell.tag == kStepperCellTagPreferredContentSizeHeight) {
        self.preferredContentSizeToUse = CGSizeMake(self.preferredContentSizeToUse.width, cell.value);
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kEHRowPreferredContentSizeHeight inSection:kEHSectionIndexControllerToPresent]]
                              withRowAnimation:UITableViewRowAnimationNone];
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
        UIScreen *mainScreen = [UIScreen mainScreen];
        self.preferredContentSizeToUse = mainScreen.bounds.size;
        NSArray *indexPathsToReload = @[[NSIndexPath indexPathForRow:kEHRowModalPresentationStyle inSection:kEHSectionIndexControllerToPresent],
                                        [NSIndexPath indexPathForRow:kEHRowPreferredContentSizeWidth inSection:kEHSectionIndexControllerToPresent],
                                        [NSIndexPath indexPathForRow:kEHRowPreferredContentSizeHeight inSection:kEHSectionIndexControllerToPresent]];
        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationNone];
    } else if (controller.tag == kSelectionControllerTagModalTransitionStyle) {
        UIModalTransitionStyle styleData = [selectedOption.data integerValue];
        self.modalTransitionStyleToUse = styleData;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kEHRowModalTransitionStyle inSection:kEHSectionIndexControllerToPresent]]
                              withRowAnimation:UITableViewRowAnimationNone];
    } else if (controller.tag == kSelectionControllerTagCustomPresentationStyle) {
        EHCustomPresentationStyle styleData = [selectedOption.data integerValue];
        self.customPresentationStyleToUse = styleData;
        self.preferredContentSizeToUse = [self defaultPreferredContentSizeForCustomPresentationStyle:self.customPresentationStyleToUse];
        NSArray *indexPathsToReload = @[[NSIndexPath indexPathForRow:kEHRowCustomPresentationStyle inSection:kEHSectionIndexControllerToPresent],
                                        [NSIndexPath indexPathForRow:kEHRowPreferredContentSizeWidth inSection:kEHSectionIndexControllerToPresent],
                                        [NSIndexPath indexPathForRow:kEHRowPreferredContentSizeHeight inSection:kEHSectionIndexControllerToPresent]];
        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationNone];
    } else if (controller.tag == kSelectionControllerTagCustomTransitionStyle) {
        EHCustomTransitionStyle styleData = [selectedOption.data integerValue];
        self.customTransitionStyleToUse = styleData;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kEHRowCustomTransitionStyle inSection:kEHSectionIndexControllerToPresent]]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - EHViewController private methods

- (void)presentButtonTapped:(id)sender {
    // Present another color controller, but this time full-screen
    EHViewController *controller = [[EHViewController alloc] initWithStyle:UITableViewStyleGrouped];

    UIViewController<EHCustomTransitionViewController> *controllerToPresent = controller;
    if (self.shouldWrapInNavigationController) {
        EHNavigationController *navController = [[EHNavigationController alloc] initWithRootViewController:controller];
        controllerToPresent = navController;
    }

    controllerToPresent.modalPresentationStyle  = self.modalPresentationStyleToUse;
    controllerToPresent.modalTransitionStyle    = self.modalTransitionStyleToUse;
    controllerToPresent.customPresentationStyle = self.customPresentationStyleToUse;
    controllerToPresent.customTransitionStyle   = self.customTransitionStyleToUse;
//    controllerToPresent.preferredContentSize    = self.preferredContentSizeToUse;
    controller.preferredContentSize             = self.preferredContentSizeToUse;

    controllerToPresent.transitioningDelegate  = (controllerToPresent.modalPresentationStyle == UIModalPresentationCustom ? self : nil);

    [self presentViewController:controllerToPresent animated:YES completion:^{
        NSLog(@"Presentation of controller completion block");
    }];
}

- (void)pushButtonTapped:(id)sender {
    EHViewController *controller = [[EHViewController alloc] initWithStyle:UITableViewStyleGrouped];

    [self.navigationController pushViewController:controller animated:YES];
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

- (NSString *)stringForCustomPresentationStyle:(EHCustomPresentationStyle)style {
    NSString *str = @"Unknown";

    for (EHCustomPresentationStyleInfo *info in self.customPresentationStyles) {
        if (info.style == style) {
            str = info.name;
            break;
        }
    }

    return str;
}

- (NSString *)stringForCustomTransitionStyle:(EHCustomTransitionStyle)style {
    NSString *str = @"Unknown";

    for (EHCustomTransitionStyleInfo *info in self.customTransitionStyles) {
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

- (NSString *)ourCustomPresentationStyle {
    NSString *style = @"Not Presented";

    if (self.presentingViewController != nil) {
        UIViewController *presentedViewController = self.presentingViewController.presentedViewController;
        style = [self stringForCustomPresentationStyle:[self customPresentationStyleForViewController:presentedViewController]];
    }

    return style;
}

- (NSString *)ourCustomTransitionStyle {
    NSString *style = @"Not Presented";

    if (self.presentingViewController != nil) {
        UIViewController *presentedViewController = self.presentingViewController.presentedViewController;
        style = [self stringForCustomTransitionStyle:[self customTransitionStyleForViewController:presentedViewController]];
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

- (NSArray *)selectionOptionsFromCustomPresentationStyles {
    NSUInteger numOptions = self.customPresentationStyles.count;
    NSMutableArray *tmpOptions = [NSMutableArray arrayWithCapacity:numOptions];
    for (NSUInteger i = 0; i < numOptions; i++) {
        EHCustomPresentationStyleInfo *ithInfo = self.customPresentationStyles[i];
        EHSelectionOption *ithOption = [[EHSelectionOption alloc] init];
        ithOption.text = ithInfo.name;
        ithOption.selected = (ithInfo.style == self.customPresentationStyleToUse);
        ithOption.data = @(ithInfo.style);
        [tmpOptions addObject:ithOption];
    }

    return [NSArray arrayWithArray:tmpOptions];
}

- (NSArray *)selectionOptionsFromCustomTransitionStyles {
    NSUInteger numOptions = self.customTransitionStyles.count;
    NSMutableArray *tmpOptions = [NSMutableArray arrayWithCapacity:numOptions];
    for (NSUInteger i = 0; i < numOptions; i++) {
        EHCustomTransitionStyleInfo *ithInfo = self.customTransitionStyles[i];
        EHSelectionOption *ithOption = [[EHSelectionOption alloc] init];
        ithOption.text = ithInfo.name;
        ithOption.selected = (ithInfo.style == self.customTransitionStyleToUse);
        ithOption.data = @(ithInfo.style);
        [tmpOptions addObject:ithOption];
    }

    return [NSArray arrayWithArray:tmpOptions];
}

- (void)showModalPresentationStylesSelectionController {
    EHSelectionTableViewController *controller = [[EHSelectionTableViewController alloc] initWithTitle:kEHModalPresentationStyleString
                                                                                          sectionTitle:nil
                                                                                      selectionOptions:[self selectionOptionsFromModalPresentationStyles]
                                                                                     canSelectMultiple:NO];
    controller.tag = kSelectionControllerTagModalPresentationStyle;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showModalTransitionStylesSelectionController {
    EHSelectionTableViewController *controller = [[EHSelectionTableViewController alloc] initWithTitle:kEHModalTransitionStyleString
                                                                                          sectionTitle:nil
                                                                                      selectionOptions:[self selectionOptionsFromModalTransitionStyles]
                                                                                     canSelectMultiple:NO];
    controller.tag = kSelectionControllerTagModalTransitionStyle;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showCustomPresentationStylesSelectionController {
    EHSelectionTableViewController *controller = [[EHSelectionTableViewController alloc] initWithTitle:kEHCustomPresentationStyleString
                                                                                          sectionTitle:nil
                                                                                      selectionOptions:[self selectionOptionsFromCustomPresentationStyles]
                                                                                     canSelectMultiple:NO];
    controller.tag = kSelectionControllerTagCustomPresentationStyle;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showCustomTransitionStyleSelectionController {
    EHSelectionTableViewController *controller = [[EHSelectionTableViewController alloc] initWithTitle:kEHCustomTransitionStyleString
                                                                                          sectionTitle:nil
                                                                                      selectionOptions:[self selectionOptionsFromCustomTransitionStyles]
                                                                                     canSelectMultiple:NO];
    controller.tag = kSelectionControllerTagCustomTransitionStyle;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (EHCustomPresentationStyle)customPresentationStyleForViewController:(UIViewController *)viewController {
    EHCustomPresentationStyle style = EHCustomPresentationStyleFullScreen;

    if ([viewController conformsToProtocol:@protocol(EHCustomTransitionViewController)]) {
        UIViewController<EHCustomTransitionViewController> *customTransitionViewController = (UIViewController<EHCustomTransitionViewController> *)viewController;
        style = customTransitionViewController.customPresentationStyle;
    }

    return style;
}

- (EHCustomTransitionStyle)customTransitionStyleForViewController:(UIViewController *)viewController {
    EHCustomTransitionStyle style = EHCustomTransitionStyleCoverVertical;

    if ([viewController conformsToProtocol:@protocol(EHCustomTransitionViewController)]) {
        UIViewController<EHCustomTransitionViewController> *customTransitionViewController = (UIViewController<EHCustomTransitionViewController> *)viewController;
        style = customTransitionViewController.customTransitionStyle;
    }

    return style;
}

+ (id<EHViewControllerAnimatedTransitioning>)animatorForCustomTransitionStyle:(EHCustomTransitionStyle)style {
    id<EHViewControllerAnimatedTransitioning> animator = nil;

    if (style == EHCustomTransitionStyleCoverVertical) {
        animator = [[EHCoverVerticalAnimationController alloc] init];
    } else if (style == EHCustomTransitionStyleCrossDissolve) {
        animator = [[EHCrossDissolveAnimationController alloc] init];
    } else if (style == EHCustomTransitionStyleZoomInWithBounce) {
        animator = [[EHZoomInAnimationController alloc] init];
    }

    return animator;
}

- (CGSize)ourPreferredContentSize {
    CGSize size = self.preferredContentSize;
    if (self.navigationController != nil) {
        size = self.navigationController.preferredContentSize;
    }

    return size;
}

- (CGSize)defaultPreferredContentSizeForCustomPresentationStyle:(EHCustomPresentationStyle)style {
    CGSize defaultSize = CGSizeZero;

    if (style == EHCustomPresentationStyleFullScreen) {
        defaultSize = [EHFullScreenPresentationController defaultPresentedSizeForViewController:self];
    } else if (style == EHCustomPresentationStyleCustomSizeDimmedBackground) {
        defaultSize = [EHDimPresentationController defaultPresentedSizeForViewController:self];
    } else if (style == EHCustomPresentationStyleCustomSizeBlurredBackground) {
        defaultSize = [EHBlurPresentationController defaultPresentedSizeForViewController:self];
    }

    return defaultSize;
}

+ (NSArray *)viewControllerInfo {
    NSMutableArray *tmpInfo = [NSMutableArray array];

    // Save the info for the root view controller
    UIApplication *application = [UIApplication sharedApplication];
    UIViewController *viewController = application.keyWindow.rootViewController;
    [EHViewController addInfoToArray:tmpInfo forController:viewController atLevel:0];

    // Now handle the presnted controller chain
    while (viewController.presentedViewController != nil) {
        UIViewController *presentedController = viewController.presentedViewController;
        [EHViewController addInfoToArray:tmpInfo forController:presentedController atLevel:0];
        viewController = presentedController;
    }

    return [NSArray arrayWithArray:tmpInfo];
}

+ (void)addInfoToArray:(NSMutableArray *)array forController:(UIViewController *)controller atLevel:(NSUInteger)level {
    EHControllerInfo *info = [EHControllerInfo infoWithController:controller level:level];
    [array addObject:info];

    NSUInteger nextLevel = level + 1;
    NSArray *childViewControllers = controller.childViewControllers;
    for (UIViewController *childViewController in childViewControllers) {
        [EHViewController addInfoToArray:array forController:childViewController atLevel:nextLevel];
    }
}

@end
