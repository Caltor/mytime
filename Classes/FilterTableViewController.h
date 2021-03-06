//
//  FilterSectionController.h
//  MyTime
//
//  Created by Brent Priddy on 3/19/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTFilter.h"
#import "GenericTableViewController.h"
#import "FilterViewController.h"
#import "FilterDetailViewController.h"

@interface FilterTableViewController : NSObject <FilterViewControllerDelegate, FilterDetailViewControllerDelegate>
{
	MTFilter *filter_;
	
}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) GenericTableViewController *tableViewController;
@property (nonatomic, retain) MTFilter *filter;
@property (nonatomic, retain) MTFilter *temporaryFilter;

- (void)constructSectionControllersForTableViewController:(GenericTableViewController *)genericTableViewController;
@end
