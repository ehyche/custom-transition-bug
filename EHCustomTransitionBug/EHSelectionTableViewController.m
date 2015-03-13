//
//  EHSelectionTableViewController.m
//  EHCustomTransitionBug
//
//  Created by Eric Hyche on 3/5/15.
//  Copyright (c) 2015 Eric Hyche. All rights reserved.
//

#import "EHSelectionTableViewController.h"
#import "EHSelectionOption.h"

@interface EHSelectionTableViewController()

@property(nonatomic, copy)   NSString *controllerTitle;
@property(nonatomic, copy)   NSString *sectionTitle;
@property(nonatomic, assign) BOOL      canSelectMultiple;
@property(nonatomic, assign) BOOL      optionsHaveSubTitle;

@property(nonatomic, strong) NSMutableArray    *mutableSelectionOptions;
@property(nonatomic, strong) NSMutableIndexSet *mutableSelectedIndexes;

@end

@implementation EHSelectionTableViewController

- (NSIndexSet *)selectedIndexes {
    return [[NSIndexSet alloc] initWithIndexSet:self.mutableSelectedIndexes];
}

- (NSArray *)selectionOptions {
    return [NSArray arrayWithArray:self.mutableSelectionOptions];
}

- (instancetype)initWithTitle:(NSString *)title
                 sectionTitle:(NSString *)sectionTitle
             selectionOptions:(NSArray *)selectionOptions
            canSelectMultiple:(BOOL)canSelectMultiple {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _controllerTitle = [title copy];
        _sectionTitle = [sectionTitle copy];
        _canSelectMultiple = canSelectMultiple;
        _mutableSelectionOptions = [NSMutableArray array];
        if (selectionOptions.count > 0) {
            [_mutableSelectionOptions setArray:selectionOptions];
        }
        _mutableSelectedIndexes = [NSMutableIndexSet indexSet];
        // Determine if we have any subtitles in our options
        for (EHSelectionOption *option in _mutableSelectionOptions) {
            if (option.detailText.length > 0) {
                _optionsHaveSubTitle = YES;
                break;
            }
        }
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.title = self.controllerTitle;
    self.navigationItem.prompt = self.navigationController.description;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mutableSelectionOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get a cell
    static NSString* const subTitleCellID = @"subTitleCellID";
    static NSString* const defaultCellID  = @"defaultCellID";
    NSString *cellIDToUse = (self.optionsHaveSubTitle ? subTitleCellID : defaultCellID);
    UITableViewCellStyle styleToUse = (self.optionsHaveSubTitle ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIDToUse];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:styleToUse reuseIdentifier:cellIDToUse];
    }

    // Look up the option
    EHSelectionOption *option = nil;
    if (indexPath.row < self.mutableSelectionOptions.count) {
        option = self.mutableSelectionOptions[indexPath.row];
    }

    // Copy the data
    cell.textLabel.text = option.text;
    if (option.detailText.length > 0) {
        cell.detailTextLabel.text = option.detailText;
    }

    // Set the selection state
    cell.accessoryType = (option.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitle;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // Look up the option
    EHSelectionOption *option = nil;
    if (indexPath.row < self.mutableSelectionOptions.count) {
        option = self.mutableSelectionOptions[indexPath.row];
    }

    BOOL didChange = YES;
    if (self.canSelectMultiple) {
        // Toggle the selected state
        option.selected = !option.selected;
    } else {
        // Only do something if it is not selected
        if (!option.selected) {
            // Clear the selected state of all options
            [self clearAllSelections];
            // Set this option to be selected
            option.selected = YES;
        } else {
            // Clear the changed flag
            didChange = NO;
        }
    }

    // Did we change state?
    if (didChange) {
        // Reload the data
        [self.tableView reloadData];
        // Rebuild the selected indexes
        [self rebuildSelectedIndexes];
        // Call back to the delegate
        [self.delegate selectionTableViewControllerDidChangeSelection:self];
    }
}

#pragma mark - EHSelectionTableViewController private methods

- (void)clearAllSelections {
    for (EHSelectionOption *option in self.mutableSelectionOptions) {
        option.selected = NO;
    }
}

- (void)rebuildSelectedIndexes {
    [self.mutableSelectedIndexes removeAllIndexes];
    for (NSUInteger i = 0; i < self.mutableSelectionOptions.count; i++) {
        EHSelectionOption *ithOption = self.mutableSelectionOptions[i];
        if (ithOption.selected) {
            [self.mutableSelectedIndexes addIndex:i];
        }
    }
}

@end
