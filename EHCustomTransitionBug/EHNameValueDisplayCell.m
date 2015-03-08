//
//  EHNameValueDisplayCell.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/7/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHNameValueDisplayCell.h"

@implementation EHNameValueDisplayCell

+ (NSString *)reuseID {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

@end
