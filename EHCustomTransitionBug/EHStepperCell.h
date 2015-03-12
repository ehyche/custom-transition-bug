//
//  EHStepperCell.h
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/10/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EHStepperCell;

@protocol EHStepperCellDelegate <NSObject>

@required

- (void)stepperCellValueDidChange:(EHStepperCell *)cell;


@end

@interface EHStepperCell : UITableViewCell

@property(nonatomic, assign) CGFloat value;

@property(nonatomic, weak) id<EHStepperCellDelegate> delegate;

+ (NSString *)reuseID;

@end
