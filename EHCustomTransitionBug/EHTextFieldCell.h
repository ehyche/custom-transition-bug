//
//  EHTextFieldCell.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/12/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHTextFieldCell : UITableViewCell

@property(nonatomic, readonly, strong) UITextField *textField;

+ (NSString *)reuseID;

@end
