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

typedef NS_ENUM(NSUInteger, EHCustomTransitionStyle) {
    EHCustomTransitionStyleNone,
    EHCustomTransitionStyleCoverVertical,
    EHCustomTransitionStyleCrossDissolve,
    EHCustomTransitionStyleCount
};

@interface EHSolidColorViewController()  <UIViewControllerTransitioningDelegate>

@property(nonatomic, assign) EHCustomTransitionStyle customTransitionStyle;

@end

@implementation EHSolidColorViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.color = [UIColor grayColor];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor = self.color;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonTapped:)];

}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* kCellID = @"SolidColorCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }

    if (indexPath.row == 0) {
        cell.textLabel.text = @"FullScreen, CoverVertical";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"FullScreen, CrossDissolve";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Custom, CoverVertical Look-alike";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Custom, CrossDissolve Look-alike";
    }

    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIModalPresentationStyle presStyle = UIModalPresentationFullScreen;
    UIModalTransitionStyle transStyle = UIModalTransitionStyleCoverVertical;
    if (indexPath.row == 0) {
        presStyle = UIModalPresentationFullScreen;
        transStyle = UIModalTransitionStyleCoverVertical;
    } else if (indexPath.row == 1) {
        presStyle = UIModalPresentationFullScreen;
        transStyle = UIModalTransitionStyleCrossDissolve;
    } else if (indexPath.row == 2) {
        presStyle = UIModalPresentationCustom;
        self.customTransitionStyle = EHCustomTransitionStyleCoverVertical;
    } else if (indexPath.row == 3) {
        presStyle = UIModalPresentationCustom;
        self.customTransitionStyle = EHCustomTransitionStyleCrossDissolve;
    }

    // Present another color controller, but this time full-screen
    EHSolidColorViewController *controller = [[EHSolidColorViewController alloc] init];
    controller.color = [UIColor blueColor];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

    navController.modalPresentationStyle = presStyle;
    navController.modalTransitionStyle = transStyle;
    navController.transitioningDelegate = (presStyle == UIModalPresentationCustom ? self : nil);

    [self presentViewController:navController animated:YES completion:^{
        NSLog(@"Presentation of navController completion block");
    }];


}

- (void)doneButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    id<UIViewControllerAnimatedTransitioning> animator = nil;

    if (self.customTransitionStyle == EHCustomTransitionStyleCoverVertical) {
        GPCoverVerticalAnimationController *coverVertical = [[GPCoverVerticalAnimationController alloc] init];
        coverVertical.dismissal = NO;
        animator = coverVertical;
    } else if (self.customTransitionStyle == EHCustomTransitionStyleCrossDissolve) {
        GPCrossDissolveAnimationController *crossDissolve = [[GPCrossDissolveAnimationController alloc] init];
        crossDissolve.dismissal = NO;
        animator = crossDissolve;
    }

    return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    id<UIViewControllerAnimatedTransitioning> animator = nil;

    if (self.customTransitionStyle == EHCustomTransitionStyleCoverVertical) {
        GPCoverVerticalAnimationController *coverVertical = [[GPCoverVerticalAnimationController alloc] init];
        coverVertical.dismissal = YES;
        animator = coverVertical;
    } else if (self.customTransitionStyle == EHCustomTransitionStyleCrossDissolve) {
        GPCrossDissolveAnimationController *crossDissolve = [[GPCrossDissolveAnimationController alloc] init];
        crossDissolve.dismissal = YES;
        animator = crossDissolve;
    }

    return animator;
}

@end
