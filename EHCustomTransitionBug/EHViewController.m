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
#import "EHTextFieldCell.h"
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

CGFloat const kEHPickerViewHeight = 100.0;
CGFloat const kEHPickerComponentWidth = 100.0;
CGFloat const kEHPickerToolbarHeight = 44.0;

NSInteger const kEHPickerMinWidth  =  100;
NSInteger const kEHPickerMaxWidth  =  768;
NSInteger const kEHPickerMinHeight =  100;
NSInteger const kEHPickerMaxHeight = 1024;

NSInteger const kEHPickerDefaultWidth  = 436;
NSInteger const kEHPickerDefaultHeight = 650;

CGFloat const kEHDefaultPreferredContentSizeWidth  =  768.0;
CGFloat const kEHDefaultPreferredContentSizeHeight = 1024.0;

typedef NS_ENUM(NSUInteger, kEHThisRowIndex) {
    kEHThisRowIndexModalPresentationStyle,
    kEHThisRowIndexModalTransitionStyle,
    kEHThisRowIndexCustomPresentationStyle,
    kEHThisRowIndexCustomTransitionStyle,
    kEHThisRowIndexPreferredContentSize,
    kEHThisRowIndexDefinesPresentationContext,
    kEHThisRowIndexCount
};

typedef NS_ENUM(NSUInteger, kEHToPresentRowIndex) {
    kEHToPresentRowIndexModalPresentationStyle,
    kEHToPresentRowIndexModalTransitionStyle,
    kEHToPresentRowIndexCustomPresentationStyle,
    kEHToPresentRowIndexCustomTransitionStyle,
    kEHToPresentRowIndexPreferredContentSize,
    kEHToPresentRowIndexWrapInNavController,
    kEHToPresentRowIndexCount
};

NSInteger const kEHSectionCount = 4;

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

static NSString * const kEHModalPresentationStyleString  = @"UIModalPresentationStyle";
static NSString * const kEHModalTransitionStyleString    = @"UIModalTransitionStyle";
static NSString * const kEHCustomPresentationStyleString = @"Custom Presentation Style";
static NSString * const kEHCustomTransitionStyleString   = @"Custom Transition Style";
static NSString * const kEHPreferredContentSizeString    = @"Preferred Content Size";

@interface EHViewController() <UIViewControllerTransitioningDelegate,
                               UITextFieldDelegate,
                               UIPickerViewDataSource,
                               UIPickerViewDelegate,
                               EHBooleanSwitchCellDelegate,
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
@property(nonatomic, strong) UIPickerView *pickerView;
@property(nonatomic, strong) UIToolbar *pickerToolbar;
@property(nonatomic, weak) UITextField *textField;

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
    [self.tableView registerClass:[EHNameValueDisplayCell class] forCellReuseIdentifier:[EHNameValueDisplayCell reuseID]];
    [self.tableView registerClass:[EHNameValueChangeCell class]  forCellReuseIdentifier:[EHNameValueChangeCell reuseID]];
    [self.tableView registerClass:[EHTextFieldCell class]        forCellReuseIdentifier:[EHTextFieldCell reuseID]];

    CGRect pickerViewFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, kEHPickerViewHeight);
    self.pickerView = [[UIPickerView alloc] initWithFrame:pickerViewFrame];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pickerView reloadAllComponents];

    CGRect pickerToolbarFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, kEHPickerToolbarHeight);
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:pickerToolbarFrame];
    self.pickerToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:NULL];
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                       target:self
                                                                                       action:@selector(pickerDoneButtonTapped:)];
    self.pickerToolbar.items = @[flexibleItem, doneBarButtonItem];


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

    self.shouldWrapInNavigationController = (self.navigationController != nil);
    self.preferredContentSizeToUse        = [self ourPreferredContentSize];
    if (CGSizeEqualToSize(self.preferredContentSizeToUse, CGSizeZero)) {
        self.preferredContentSizeToUse = CGSizeMake(kEHDefaultPreferredContentSizeWidth, kEHDefaultPreferredContentSizeHeight);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.navigationController != nil) {
        // Set the title
        self.navigationItem.title = [NSString stringWithFormat:@"Controller %@", @(self.controllerIndex)];
        self.navigationItem.prompt = self.navigationController.description;
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
        numRows = kEHThisRowIndexCount;
    } else if (section == kEHSectionIndexControllerToPresent) {
        numRows = kEHToPresentRowIndexCount;
    } else if (section == kEHSectionIndexPresentedController ||
               section == kEHSectionIndexPresentingController) {
        numRows = self.controllerInfo.count;
    }

    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseID = nil;
    if (indexPath.section == kEHSectionIndexThisController) {
        if (indexPath.row == kEHThisRowIndexDefinesPresentationContext) {
            reuseID = [EHBooleanSwitchCell reuseID];
        } else {
            reuseID = [EHNameValueDisplayCell reuseID];
        }
    } else if (indexPath.section == kEHSectionIndexControllerToPresent) {
        if (indexPath.row == kEHToPresentRowIndexWrapInNavController) {
            reuseID = [EHBooleanSwitchCell reuseID];
        } else if (indexPath.row == kEHToPresentRowIndexPreferredContentSize) {
            reuseID = [EHTextFieldCell reuseID];
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
    NSUInteger indentLevel = 0;
    if (indexPath.section == kEHSectionIndexThisController) {
        if (indexPath.row == kEHThisRowIndexModalPresentationStyle) {
            text = kEHModalPresentationStyleString;
            detailText = [self ourModalPresentationStyle];
        } else if (indexPath.row == kEHThisRowIndexModalTransitionStyle) {
            text = kEHModalTransitionStyleString;
            detailText = [self ourModalTransitionStyle];
        } else if (indexPath.row == kEHThisRowIndexCustomPresentationStyle) {
            text = kEHCustomPresentationStyleString;
            detailText = [self ourCustomPresentationStyle];
        } else if (indexPath.row == kEHThisRowIndexCustomTransitionStyle) {
            text = kEHCustomTransitionStyleString;
            detailText = [self ourCustomTransitionStyle];
        } else if (indexPath.row == kEHThisRowIndexPreferredContentSize) {
            text = kEHPreferredContentSizeString;
            CGSize size = [self ourPreferredContentSize];
            detailText = NSStringFromCGSize(size);
        } else if (indexPath.row == kEHThisRowIndexDefinesPresentationContext) {
            text = @"Defines Presentation Context";
            cellOn = self.definesPresentationContext;
            booleanCellTag = kBooleanCellTagDefinesPresentationContext;
        }
    } else if (indexPath.section == kEHSectionIndexControllerToPresent) {
        if (indexPath.row == kEHToPresentRowIndexModalPresentationStyle) {
            text = kEHModalPresentationStyleString;
            detailText = [self stringForModalPresentationStyle:self.modalPresentationStyleToUse];
        } else if (indexPath.row == kEHToPresentRowIndexModalTransitionStyle) {
            text = kEHModalTransitionStyleString;
            detailText = [self stringForModalTransitionStyle:self.modalTransitionStyleToUse];
        } else if (indexPath.row == kEHToPresentRowIndexCustomPresentationStyle) {
            text = kEHCustomPresentationStyleString;
            detailText = [self stringForCustomPresentationStyle:self.customPresentationStyleToUse];
        } else if (indexPath.row == kEHToPresentRowIndexCustomTransitionStyle) {
            text = kEHCustomTransitionStyleString;
            detailText = [self stringForCustomTransitionStyle:self.customTransitionStyleToUse];
        } else if (indexPath.row == kEHToPresentRowIndexPreferredContentSize) {
            text = kEHPreferredContentSizeString;
            detailText = NSStringFromCGSize(self.preferredContentSizeToUse);
        } else if (indexPath.row == kEHToPresentRowIndexWrapInNavController) {
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

    if ([cell isKindOfClass:[EHTextFieldCell class]]) {
        EHTextFieldCell *textFieldCell = (EHTextFieldCell *)cell;
        textFieldCell.textField.delegate = self;
        textFieldCell.textField.text = detailText;
        textFieldCell.detailTextLabel.text = detailText;
        textFieldCell.textField.inputView = self.pickerView;
        textFieldCell.textField.inputAccessoryView = self.pickerToolbar;
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
        if (indexPath.row == kEHToPresentRowIndexModalPresentationStyle) {
            // Let the user choose a modal presentation style
            [self showModalPresentationStylesSelectionController];
        } else if (indexPath.row == kEHToPresentRowIndexModalTransitionStyle) {
            // Let the user choose a modal transition style
            [self showModalTransitionStylesSelectionController];
        } else if (indexPath.row == kEHToPresentRowIndexCustomPresentationStyle) {
            // Let the user choose a custom presentation style
            [self showCustomPresentationStylesSelectionController];
        } else if (indexPath.row == kEHToPresentRowIndexCustomTransitionStyle) {
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

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.textField = textField;

    // Parse the text field. It should be (width,height).
    NSArray *components = [textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{,}"]];
    NSMutableArray *nonZeroLengthComponents = [NSMutableArray array];
    for (NSString *component in components) {
        if (component.length > 0) {
            [nonZeroLengthComponents addObject:component];
        }
    }

    // Width should be the first, Height the 2nd
    NSInteger width = 0;
    NSInteger height = 0;
    if (nonZeroLengthComponents.count > 0) {
        NSString *firstStr = nonZeroLengthComponents.firstObject;
        width = [firstStr integerValue];
    }
    if (nonZeroLengthComponents.count > 1) {
        NSString *secondStr = nonZeroLengthComponents[1];
        height = [secondStr integerValue];
    }

    width = MAX(width, kEHPickerMinWidth);
    width = MIN(width, kEHPickerMaxWidth);

    height = MAX(height, kEHPickerMinHeight);
    height = MIN(height, kEHPickerMaxHeight);

    // Compute the width index and height index
    NSInteger widthIndex = width - kEHPickerMinWidth;
    NSInteger heightIndex = height - kEHPickerMinHeight;

    // Set the picker to these rows
    [self.pickerView selectRow:widthIndex inComponent:0 animated:NO];
    [self.pickerView selectRow:heightIndex inComponent:1 animated:NO];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.textField = nil;
}

#pragma mark - UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numRows = 0;

    if (component == 0) {
        numRows = kEHPickerMaxWidth - kEHPickerMinWidth + 1;
    } else {
        numRows = kEHPickerMaxHeight - kEHPickerMinHeight + 1;
    }

    return numRows;
}

#pragma mark - UIPickerViewDelegate methods

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return kEHPickerComponentWidth;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger minValue = (component == 0 ? kEHPickerMinWidth : kEHPickerMinHeight);
    NSInteger rowValue = minValue + row;
    return [@(rowValue) stringValue];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // Compute the selected width and height
    NSInteger widthIndex = [self.pickerView selectedRowInComponent:0];
    NSInteger heightIndex = [self.pickerView selectedRowInComponent:1];
    CGFloat width = kEHPickerMinWidth + widthIndex;
    CGFloat height = kEHPickerMinHeight + heightIndex;

    self.preferredContentSizeToUse = CGSizeMake(width, height);
    self.textField.text = NSStringFromCGSize(self.preferredContentSizeToUse);
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
        UIScreen *mainScreen = [UIScreen mainScreen];
        self.preferredContentSizeToUse = mainScreen.bounds.size;
        NSArray *indexPathsToReload = @[[NSIndexPath indexPathForRow:kEHToPresentRowIndexModalPresentationStyle inSection:kEHSectionIndexControllerToPresent],
                                        [NSIndexPath indexPathForRow:kEHToPresentRowIndexPreferredContentSize inSection:kEHSectionIndexControllerToPresent]];
        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationNone];
    } else if (controller.tag == kSelectionControllerTagModalTransitionStyle) {
        UIModalTransitionStyle styleData = [selectedOption.data integerValue];
        self.modalTransitionStyleToUse = styleData;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kEHToPresentRowIndexModalTransitionStyle inSection:kEHSectionIndexControllerToPresent]]
                              withRowAnimation:UITableViewRowAnimationNone];
    } else if (controller.tag == kSelectionControllerTagCustomPresentationStyle) {
        EHCustomPresentationStyle styleData = [selectedOption.data integerValue];
        self.customPresentationStyleToUse = styleData;
        self.preferredContentSizeToUse = [self defaultPreferredContentSizeForCustomPresentationStyle:self.customPresentationStyleToUse];
        NSArray *indexPathsToReload = @[[NSIndexPath indexPathForRow:kEHToPresentRowIndexCustomPresentationStyle inSection:kEHSectionIndexControllerToPresent],
                                        [NSIndexPath indexPathForRow:kEHToPresentRowIndexPreferredContentSize inSection:kEHSectionIndexControllerToPresent]];
        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationNone];
    } else if (controller.tag == kSelectionControllerTagCustomTransitionStyle) {
        EHCustomTransitionStyle styleData = [selectedOption.data integerValue];
        self.customTransitionStyleToUse = styleData;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kEHToPresentRowIndexCustomTransitionStyle inSection:kEHSectionIndexControllerToPresent]]
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
    controllerToPresent.preferredContentSize    = self.preferredContentSizeToUse;

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

- (void)pickerDoneButtonTapped:(id)sender {
    // Compute the selected width and height
    NSInteger widthIndex = [self.pickerView selectedRowInComponent:0];
    NSInteger heightIndex = [self.pickerView selectedRowInComponent:1];
    CGFloat width = kEHPickerMinWidth + widthIndex;
    CGFloat height = kEHPickerMinHeight + heightIndex;

    self.preferredContentSizeToUse = CGSizeMake(width, height);
    NSIndexPath *contentSizeIndexPath = [NSIndexPath indexPathForRow:kEHToPresentRowIndexPreferredContentSize inSection:kEHSectionIndexControllerToPresent];
    [self.tableView reloadRowsAtIndexPaths:@[contentSizeIndexPath] withRowAnimation:UITableViewRowAnimationNone];

    [self.textField resignFirstResponder];
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
