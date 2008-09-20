//
//  AddressViewController.h
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewTextFieldCell.h"
#import "AddressViewControllerDelegate.h"

@interface AddressViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
	id<AddressViewControllerDelegate> delegate;
	UITableView *theTableView;

	UITableViewTextFieldCell *streetNumberCell;
    UITableViewTextFieldCell *streetCell;
    UITableViewTextFieldCell *cityCell;
    UITableViewTextFieldCell *stateCell;

	NSString *streetNumber;
    NSString *street;
    NSString *city;
    NSString *state;
}

@property (nonatomic,retain) id<AddressViewControllerDelegate> delegate;
@property (nonatomic,retain) UITableView *theTableView;

@property (nonatomic,retain) NSString *streetNumber;
@property (nonatomic,retain) NSString *street;
@property (nonatomic,retain) NSString *city;
@property (nonatomic,retain) NSString *state;
@property (nonatomic,retain) UITableViewTextFieldCell *streetNumberCell;
@property (nonatomic,retain) UITableViewTextFieldCell *streetCell;
@property (nonatomic,retain) UITableViewTextFieldCell *cityCell;
@property (nonatomic,retain) UITableViewTextFieldCell *stateCell;



/**
 * initialize this view 
 *
 * @param rect - the rect
 * @returns self
 */
- (id) init;

/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithStreetNumber:(NSString *)streetNumber street:(NSString *)street city:(NSString *)city state:(NSString *)state;

- (void)navigationControlDone:(id)sender;

@end




