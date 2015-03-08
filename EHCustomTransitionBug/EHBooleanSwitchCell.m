//
//  EHBooleanSwitchCell.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/7/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHBooleanSwitchCell.h"

@interface EHBooleanSwitchCell()

@property(nonatomic, strong) UISwitch *accessorySwitch;

@end

@implementation EHBooleanSwitchCell

- (BOOL)isOn {
    return self.accessorySwitch.isOn;
}

- (void)setOn:(BOOL)on {
    self.accessorySwitch.on = on;
}

+ (NSString *)reuseID {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _accessorySwitch = [[UISwitch alloc] init];
        self.accessoryView = _accessorySwitch;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

#pragma mark - EHBooleanSwitchCell private methods

- (void)switchValueChanged:(id)sender {
    [self.delegate booleanSwitchCellValueChanged:self];
}

@end
