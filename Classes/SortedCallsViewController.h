//
//  SortedByStreetViewController.h
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import "SortedCallsViewDataSourceProtocol.h"
#import "CallViewController.h"
#import "EmptyListViewController.h"
#import <CoreData/CoreData.h>
#import "PSExtendedFetchedResultsController.h"

@interface SortedCallsViewController : UIViewController <UITableViewDelegate, 
                                                         UITableViewDataSource,
														 CallViewControllerDelegate, 
														 UISearchBarDelegate, 
                                                         NSFetchedResultsControllerDelegate, 
                                                         UISearchDisplayDelegate> 
{
	id<SortedCallsViewDataSourceProtocol> dataSource;
	NSIndexPath *indexPath;
	BOOL searching;
	UIBarButtonItem *savedLeftButton;
	BOOL savedHidesBackButton;
	EmptyListViewController *emptyView;
	MTCall *editingCall;
	UITableView *tableView_;
	UILabel *footerLabel_;
	
	BOOL reloadData_;
    PSExtendedFetchedResultsController *fetchedResultsController_;
    PSExtendedFetchedResultsController *searchFetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;

	// The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;

	bool coreDataHasChangeContentBug;
}
@property (nonatomic, retain) EmptyListViewController *emptyView;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) id<SortedCallsViewDataSourceProtocol> dataSource;
@property (nonatomic, retain) NSIndexPath *indexPath;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) PSExtendedFetchedResultsController *fetchedResultsController;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;


- (id)initWithDataSource:(id<SortedCallsViewDataSourceProtocol>)theDataSource;
- (void)reloadTableFromSourceChange;

@end
