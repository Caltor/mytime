//
//  PSBaseCellController.h
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"


@interface PSBaseCellController : NSObject<TableViewCellController>
{
@private
	NSObject *model_;
	NSString *modelPath_;
	id selectionTarget_;
	SEL selectionAction_;
	id deleteTarget_;
	SEL deleteAction_;
	id insertTarget_;
	SEL insertAction_;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSObject *model;
@property (nonatomic, copy) NSString *modelPath;
@property (nonatomic, assign) BOOL indentWhileEditing;
@property (nonatomic, assign) UITableViewCellEditingStyle editingStyle;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, retain) UIView *accessoryView;
@property (nonatomic, retain) UIView *editingAccessoryView;
@property (nonatomic, assign) UITableViewCellAccessoryType editingAccessoryType;
//@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, assign) GenericTableViewController *tableViewController;
@property (nonatomic, copy) NSIndexPath *selectedRow;
// 0 means to not go to the next row
@property (nonatomic, assign) int selectNextRowResponderIncrement;
@property (nonatomic, assign) int selectNextSectionResponderIncrement;
@property (nonatomic, retain) UIResponder *nextRowResponder;
@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, assign) BOOL movableWhileEditing;
@property (nonatomic, assign) BOOL movable;
@property (nonatomic, assign) BOOL isViewableWhenEditing;
@property (nonatomic, assign) BOOL isViewableWhenNotEditing;
@property (nonatomic, retain) NSObject *userData;

- (UIResponder *)nextRowResponderForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

// selector in the form of baseCellController:(PSBaseCellController *)baseCellController tableview:(UITableView *)didSelectAtIndexPath:(NSIndexPath *)
- (void)setSelectionTarget:(id)target action:(SEL)action;

// selector in the form of - (void)baseCellController:(PSBaseCellController *)baseCellController tableView:(UITableView *)tableView deleteActionForRowAtIndexPath:(NSIndexPath *)indexPath
- (void)setDeleteTarget:(id)target action:(SEL)action;

// selector in the form of - (void)baseCellController:(PSBaseCellController *)baseCellController tableView:(UITableView *)tableView insertActionForRowAtIndexPath:(NSIndexPath *)indexPath
- (void)setInsertTarget:(id)target action:(SEL)action;

- (id)init;
@end