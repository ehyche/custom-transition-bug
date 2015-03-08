//
//  EHBooleanSwitchCell.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/7/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EHBooleanSwitchCell;

@protocol EHBooleanSwitchCellDelegate <NSObject>

@required
- (void)booleanSwitchCellValueChanged:(EHBooleanSwitchCell *)cell;

@end

@interface EHBooleanSwitchCell : UITableViewCell

@property(nonatomic, assign, getter=isOn) BOOL on;
@property(nonatomic, weak) id<EHBooleanSwitchCellDelegate> delegate;

+ (NSString *)reuseID;

@end
