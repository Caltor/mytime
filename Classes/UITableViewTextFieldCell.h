//
//  UITableViewTextFieldCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/27/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UITableViewTextFieldCellDelegate.h"

@interface UITableViewTextFieldCell : UITableViewCell <UITextFieldDelegate> {
	UITextField *textField;
	UILabel *titleLabel;
	UIResponder *nextKeyboardResponder;
	NSIndexPath *indexPath;
	UITableView *tableView;
	
	id<UITableViewTextFieldCellDelegate> delegate;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UIResponder *nextKeyboardResponder;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, assign) id<UITableViewTextFieldCellDelegate> delegate;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end

