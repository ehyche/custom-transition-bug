//
//  ViewController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "ViewController.h"
#import "EHSolidColorViewController.h"
#import "GPFadeWithBlurredBackgroundAnimationController.h"

@interface ViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentButtonTapped:(id)sender {
    EHSolidColorViewController *controller = [[EHSolidColorViewController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.color = [UIColor redColor];

//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
//    navController.transitioningDelegate = self;
//    navController.modalPresentationStyle = UIModalPresentationCustom;
//    [self presentViewController:navController animated:YES completion:^{
//        NSLog(@"Presentation of navController completion block");
//    }];

    controller.transitioningDelegate = self;
    controller.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:controller animated:YES completion:^{
        NSLog(@"Presentation of navController completion block");
    }];

}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    GPFadeWithBlurredBackgroundAnimationController *animator = [[GPFadeWithBlurredBackgroundAnimationController alloc] init];
    animator.dismissal = NO;
    return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    GPFadeWithBlurredBackgroundAnimationController *animator = [[GPFadeWithBlurredBackgroundAnimationController alloc] init];
    animator.dismissal = YES;
    return animator;
}

@end
