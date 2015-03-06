//
//  EHSolidColorViewController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHSolidColorViewController.h"
#import "GPCoverVerticalAnimationController.h"
#import "GPCrossDissolveAnimationController.h"
#import "GPFadeWithBlurredBackgroundAnimationController.h"
#import "EHModalPresentationStyleInfo.h"
#import "EHModalTransitionStyleInfo.h"

CGFloat const kButtonHeight = 44.0;
CGFloat const kButtonPadding = 5.0;

#define SYSTEM_VERSION_LESS_THAN(v)                   ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


typedef NS_ENUM(NSUInteger, EHCustomTransitionStyle) {
    EHCustomTransitionStyleNone,
    EHCustomTransitionStyleCoverVertical,
    EHCustomTransitionStyleCrossDissolve,
    EHCustomTransitionStyleFadeInWithDimmedBackground,
    EHCustomTransitionStyleCount
};

@interface EHCustomTransitionInfo : NSObject

@property(nonatomic, assign) EHCustomTransitionStyle style;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) BOOL selected;

+ (EHCustomTransitionInfo *)infoWithStyle:(EHCustomTransitionStyle)style name:(NSString *)name;

@end

@implementation EHCustomTransitionInfo

+ (EHCustomTransitionInfo *)infoWithStyle:(EHCustomTransitionStyle)style name:(NSString *)name {
    EHCustomTransitionInfo *info = [[EHCustomTransitionInfo alloc] init];
    info.style = style;
    info.name = name;
    return info;
}

@end

@interface EHSolidColorViewController()  <UIViewControllerTransitioningDelegate>

@property(nonatomic, assign) EHCustomTransitionStyle customTransitionStyle;
@property(nonatomic, strong) UILabel *headerView;
@property(nonatomic, strong) UIButton *presentButton;
@property(nonatomic, strong) UIButton *doneButton;
@property(nonatomic, strong) UIView *footerContainerView;
@property(nonatomic, copy)   NSArray *modalPresentationStyles;
@property(nonatomic, copy)   NSArray *modalTransitionStyles;
@property(nonatomic, copy)   NSArray *customTransitionStyles;

@end

@implementation EHSolidColorViewController

- (void)awakeFromNib {
    NSLog(@"awakeFromNib");
    [self commonInit];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];


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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 0;

    if (section == 0) {
        BOOL isPreIOS8 = SYSTEM_VERSION_LESS_THAN(@"8.0");
        numRows = (isPreIOS8 ? 5 : self.modalPresentationStyles.count);
    } else if (section == 1) {
        numRows = self.modalTransitionStyles.count;
    } else if (section == 2) {
        numRows = self.customTransitionStyles.count;
    }

    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* kCellID = @"SolidColorCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }

    NSString *text = nil;
    BOOL selected = NO;
    if (indexPath.section == 0) {
        EHModalPresentationStyleInfo *info = [self.modalPresentationStyles objectAtIndex:indexPath.row];
        text = info.name;
        selected = info.selected;
    } else if (indexPath.section == 1) {
        EHModalTransitionStyleInfo *info = [self.modalTransitionStyles objectAtIndex:indexPath.row];
        text = info.name;
        selected = info.selected;
    } else if (indexPath.section == 2) {
        EHCustomTransitionInfo *info = [self.customTransitionStyles objectAtIndex:indexPath.row];
        text = info.name;
        selected = info.selected;
    }
    cell.textLabel.text = text;
    cell.accessoryType = (selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;

    if (section == 0) {
        title = @"Modal Presentation Style";
    } else if (section == 1) {
        title = @"Modal Transition Style";
    } else if (section == 2) {
        title = @"Custom Transition Type";
    }

    return title;
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        [self clearAllModalPresentationStyleSelections];
        [self selectModalPresentationStyleWithIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        [self clearAllModalTransitionStyleSelections];
        [self selectModalTransitionStyleWithIndex:indexPath.row];
    } else if (indexPath.section == 2) {
        [self clearAllCustomTransitionStyleSelections];
        [self selectCustomTransitionStyleWithIndex:indexPath.row];
    }
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    id<UIViewControllerAnimatedTransitioning> animator = nil;

    EHCustomTransitionStyle style = [self selectedCustomTransitionStyle];

    if (style == EHCustomTransitionStyleCoverVertical) {
        GPCoverVerticalAnimationController *coverVertical = [[GPCoverVerticalAnimationController alloc] init];
        coverVertical.dismissal = NO;
        animator = coverVertical;
    } else if (style == EHCustomTransitionStyleCrossDissolve) {
        GPCrossDissolveAnimationController *crossDissolve = [[GPCrossDissolveAnimationController alloc] init];
        crossDissolve.dismissal = NO;
        animator = crossDissolve;
    } else if (style == EHCustomTransitionStyleFadeInWithDimmedBackground) {
        GPFadeWithBlurredBackgroundAnimationController *fade = [[GPFadeWithBlurredBackgroundAnimationController alloc] init];
        fade.dismissal = NO;
        animator = fade;
    }

    return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    id<UIViewControllerAnimatedTransitioning> animator = nil;

    EHCustomTransitionStyle style = [self selectedCustomTransitionStyle];

    if (style == EHCustomTransitionStyleCoverVertical) {
        GPCoverVerticalAnimationController *coverVertical = [[GPCoverVerticalAnimationController alloc] init];
        coverVertical.dismissal = YES;
        animator = coverVertical;
    } else if (style == EHCustomTransitionStyleCrossDissolve) {
        GPCrossDissolveAnimationController *crossDissolve = [[GPCrossDissolveAnimationController alloc] init];
        crossDissolve.dismissal = YES;
        animator = crossDissolve;
    } else if (style == EHCustomTransitionStyleFadeInWithDimmedBackground) {
        GPFadeWithBlurredBackgroundAnimationController *fade = [[GPFadeWithBlurredBackgroundAnimationController alloc] init];
        fade.dismissal = YES;
        animator = fade;
    }

    return animator;
}

#pragma mark - EHSolidColorViewController private methods

- (void)presentButtonTapped:(id)sender {

    UIModalPresentationStyle modalPresentationStyle = [self selectedModalPresentationStyle];
    UIModalTransitionStyle   modalTransitionStyle   = [self selectedModalTransitionStyle];

    // Present another color controller, but this time full-screen
    EHSolidColorViewController *controller = [[EHSolidColorViewController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.controllerIndex = self.controllerIndex + 1;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

    navController.modalPresentationStyle = modalPresentationStyle;

    if (modalPresentationStyle == UIModalPresentationCustom) {
        navController.transitioningDelegate = self;
    } else {
        navController.transitioningDelegate = nil;
        navController.modalTransitionStyle = modalTransitionStyle;
    }

    [self presentViewController:navController animated:YES completion:^{
        NSLog(@"Presentation of controller completion block");
    }];
}

- (void)doneButtonTapped:(id)sender {
    if (self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)clearAllModalPresentationStyleSelections {
    for (EHModalPresentationStyleInfo *info in self.modalPresentationStyles) {
        info.selected = NO;
    }
}

- (void)clearAllModalTransitionStyleSelections {
    for (EHModalTransitionStyleInfo *info in self.modalTransitionStyles) {
        info.selected = NO;
    }
}

- (void)clearAllCustomTransitionStyleSelections {
    for (EHCustomTransitionInfo *info in self.customTransitionStyles) {
        info.selected = NO;
    }
}

- (void)selectModalPresentationStyleWithIndex:(NSInteger)index {
    if (index < self.modalPresentationStyles.count) {
        EHModalPresentationStyleInfo *info = self.modalPresentationStyles[index];
        info.selected = YES;
    }
}

- (void)selectModalTransitionStyleWithIndex:(NSInteger)index {
    if (index < self.modalTransitionStyles.count) {
        EHModalTransitionStyleInfo *info = self.modalTransitionStyles[index];
        info.selected = YES;
    }
}

- (void)selectCustomTransitionStyleWithIndex:(NSInteger)index {
    if (index < self.customTransitionStyles.count) {
        EHCustomTransitionInfo *info = self.customTransitionStyles[index];
        info.selected = YES;
    }
}

- (UIModalPresentationStyle) selectedModalPresentationStyle {
    UIModalPresentationStyle style = UIModalPresentationNone;

    for (EHModalPresentationStyleInfo *info in self.modalPresentationStyles) {
        if (info.selected) {
            style = info.style;
            break;
        }
    }

    return style;
}

- (UIModalTransitionStyle)selectedModalTransitionStyle {
    UIModalTransitionStyle style = UIModalTransitionStyleCoverVertical;

    for (EHModalTransitionStyleInfo *info in self.modalTransitionStyles) {
        if (info.selected) {
            style = info.style;
            break;
        }
    }

    return style;
}

- (EHCustomTransitionStyle)selectedCustomTransitionStyle {
    EHCustomTransitionStyle style = EHCustomTransitionStyleNone;

    for (EHCustomTransitionInfo *info in self.customTransitionStyles) {
        if (info.selected) {
            style = info.style;
            break;
        }
    }

    return style;
}

- (void)commonInit {
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

    // Initialize the selected transition styles
    [self selectModalPresentationStyleWithIndex:0];
    [self selectModalTransitionStyleWithIndex:0];
    [self selectCustomTransitionStyleWithIndex:0];
}

@end
