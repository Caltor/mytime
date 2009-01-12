//
//  NotesViewControllerDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//


@class NotesViewController;

@protocol NotesViewControllerDelegate<NSObject>

@required

- (void)notesViewControllerDone:(NotesViewController *)notesViewController;

@end

