//
//  EHStepperCell.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/10/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHStepperCell.h"

@interface EHStepperCell()

@property(nonatomic, strong) UIStepper *stepper;

@end

@implementation EHStepperCell

- (CGFloat)value {
    return (CGFloat)self.stepper.value;
}

- (void)setValue:(CGFloat)value {
    self.stepper.value = value;
}

+ (NSString *)reuseID {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        _stepper = [[UIStepper alloc] init];
        _stepper.minimumValue = 100.0;
        _stepper.maximumValue = 1024.0;
        _stepper.stepValue    = 1.0;
        [_stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = _stepper;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

#pragma mark - EHStepperCell private methods

- (void)stepperValueChanged:(id)sender {
    [self.delegate stepperCellValueDidChange:self];
}

@end
