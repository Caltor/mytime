//
//  NotAtHomeViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import "NotAtHomeTerritoryViewController.h"
#import "EmptyListViewController.h"
#import "MTTerritory.h"
#import <CoreData/CoreData.h>

@interface NotAtHomeViewController : UITableViewController <NotAtHomeTerritoryViewControllerDelegate, NSFetchedResultsControllerDelegate>
{
@private
	EmptyListViewController *emptyView;
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
	bool reloadData_;
	MTTerritory *temporaryTerritory;

	bool coreDataHasChangeContentBug;
}
@property (nonatomic, retain) EmptyListViewController *emptyView;
@property (nonatomic, retain) MTTerritory *temporaryTerritory;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
