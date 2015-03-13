//
//  EHTextFieldCell.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/12/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHTextFieldCell.h"

@interface EHTextFieldCell()

@property(nonatomic, readwrite, strong) UITextField *textField;

@end

@implementation EHTextFieldCell

+ (NSString *)reuseID {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        _textField = [[UITextField alloc] initWithFrame:self.contentView.bounds];
        _textField.font = self.detailTextLabel.font;
        _textField.textColor = self.detailTextLabel.textColor;
        _textField.textAlignment = self.detailTextLabel.textAlignment;
        _textField.adjustsFontSizeToFitWidth = self.detailTextLabel.adjustsFontSizeToFitWidth;
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_textField];

        self.detailTextLabel.hidden = YES;
    }

    return self;
}

@end
