//
//  CallViewController.h
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewTextFieldCell.h"
#import "AddressViewController.h"
#import "AddressViewControllerDelegate.h"
#import "PublicationViewControllerDelegate.h"
#import "CallViewControllerDelegate.h"
#import "DatePickerViewControllerDelegate.h"
#import "UITableViewTextFieldCellDelegate.h"
#import "NotesViewControllerDelegate.h"
#import "SwitchTableCell.h"

@interface CallViewController : UIViewController <UITableViewDelegate, 
                                                  UITableViewDataSource, 
												  UIActionSheetDelegate, 
												  PublicationViewControllerDelegate,
												  AddressViewControllerDelegate,
												  DatePickerViewControllerDelegate,
												  UITableViewTextFieldCellDelegate,
												  NotesViewControllerDelegate,
												  SwitchTableCellDelegate> 
{
	UITableView *theTableView;
	
	BOOL _initialView;
	
    UITableViewTextFieldCell *_name;

    NSMutableDictionary *_call;
	
	NSMutableArray *_displayInformation;
	NSMutableDictionary *_currentGroup;
	
	UIResponder *currentFirstResponder;
	NSIndexPath *currentIndexPath;
	
	BOOL _showAddCall;
	BOOL _showDeleteButton;
	BOOL _newCall;
	BOOL _editing;
	BOOL _shouldReloadAll;
	
	int _selectedRow;
	int _setFirstResponderGroup;

    // this will be set to the publication that we are changing
    // or nil when we are adding a publication
    NSMutableDictionary *_editingPublication;
    // this will be set to the particular returnvisit that we are modifying
    NSMutableDictionary *_editingReturnVisit;

	id<CallViewControllerDelegate> delegate;
}
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic, assign) id<CallViewControllerDelegate> delegate;
@property (nonatomic, retain) UIResponder *currentFirstResponder;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;


/**
 * @returns the call we are editing
 */
- (NSMutableDictionary *)call;

/**
 * @returns the call's name
 */
- (NSString *)name;

/**
 * @returns the call's street
 */
- (NSString *)street;    

/**
 * @returns the call's city
 */
- (NSString *)city;

/**
 * @returns the call's state
 */
- (NSString *)state;

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithCall:(NSMutableDictionary *)call;
- (id) init;
- (void)dealloc;

// dont use this
- (void)reloadData;

@end


