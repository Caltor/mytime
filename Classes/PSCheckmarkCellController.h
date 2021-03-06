//
//  PSCheckmarkCellController.h
//  MyTime
//
//  Created by Brent Priddy on 2/3/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseCellController.h"
#import "UITableViewSwitchCell.h"

@interface PSCheckmarkCellController : PSBaseCellController
{
	BOOL isChecked;
}
@property (nonatomic, retain) NSObject *checkedValue;
@property (nonatomic, retain) UITableView *cachedTableView;
@property (nonatomic, retain) NSIndexPath *cachedIndexPath;

@end
