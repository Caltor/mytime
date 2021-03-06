//
//  StatisticsTableViewController.m
//  MyTime
//
//  Created by Brent Priddy on 4/9/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "StatisticsTableViewController.h"
#import "UITableViewTitleAndValueCell.h"
#import "PSUrlString.h"
#import "MTSettings.h"
#import "MTUser.h"
#import "MTCall.h"
#import "MTReturnVisit.h"
#import "MTPublication.h"
#import "MTBulkPlacement.h"
#import "MTTimeType.h"
#import "MTTimeEntry.h"
#import "MTStatisticsAdjustment.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"
#import "StatisticsNumberCell.h"
#import "HourPickerViewController.h"
#import "StatisticsCallsTableViewController.h"

#include "PSRemoveLocalizedString.h"
static NSString *MONTHS[] = {
	NSLocalizedString(@"January", @"Long month name"),
	NSLocalizedString(@"February", @"Long month name"),
	NSLocalizedString(@"March", @"Long month name"),
	NSLocalizedString(@"April", @"Long month name"),
	NSLocalizedString(@"May", @"Short/Long month name"),
	NSLocalizedString(@"June", @"Long month name"),
	NSLocalizedString(@"July", @"Long month name"),
	NSLocalizedString(@"August", @"Long month name"),
	NSLocalizedString(@"September", @"Long month name"),
	NSLocalizedString(@"October", @"Long month name"),
	NSLocalizedString(@"November", @"Long month name"),
	NSLocalizedString(@"December", @"Long month name")
};
#include "PSAddLocalizedString.h"

NSString * const StatisticsTypeHours = @"Hours";
NSString * const StatisticsTypeBooks = @"Books";
NSString * const StatisticsTypeBrochures = @"Brochures";
NSString * const StatisticsTypeMagazines = @"Magazines";
NSString * const StatisticsTypeReturnVisits = @"Return Visits";
NSString * const StatisticsTypeBibleStudies = @"Bible Studies";
NSString * const StatisticsTypeCampaignTracts = @"Campaign Tracts";
NSString * const StatisticsTypeRBCHours = @"RBC Hours";

/******************************************************************
 *
 *   ServiceYearStatisticsCellController
 *
 ******************************************************************/
#pragma mark ServiceYearStatisticsCellController
@interface ServiceYearStatisticsCellController : NSObject<TableViewCellController>
{
	NSString *ps_title;
	int *ps_serviceYearValue;
	BOOL ps_isHours;
	NSArray *calls;
	StatisticsTableViewController *delegate;
	BOOL displayIfZero;
}
@property (nonatomic, assign) StatisticsTableViewController *delegate;
@property (nonatomic, retain) NSArray *calls;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) BOOL displayIfZero;
@end
@implementation ServiceYearStatisticsCellController
@synthesize title = ps_title;
@synthesize calls;
@synthesize delegate;
@synthesize displayIfZero;

- (id)initWithTitle:(NSString *)title serviceYearValue:(int *)serviceYearValue isHours:(BOOL)isHours
{
	if( (self = [super init]) )
	{
		self.title = title;
		ps_serviceYearValue = serviceYearValue;
		ps_isHours = isHours;
	}
	return self;
}

- (id)initWithTitle:(NSString *)title serviceYearValue:(int *)serviceYearValue
{
	return [self initWithTitle:title serviceYearValue:serviceYearValue isHours:NO];
}

- (void)dealloc
{
	self.calls = nil;
	self.title = nil;
	[super dealloc];
}

- (BOOL)isViewableWhenNotEditing
{
	return *(ps_serviceYearValue) != 0 || displayIfZero;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"ServiceYearStatisticsCellController";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.textLabel.text = self.title;
	if(ps_isHours)
	{
		int value = *(ps_serviceYearValue);
		int hours = value / 60;
		int minutes = value % 60;
		if(hours && minutes)
			cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
		else if(hours)
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
		else if(minutes)
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
		else
			cell.detailTextLabel.text = @"0";
	}
	else 
	{
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", *(ps_serviceYearValue)];
	}
	
	if(self.calls)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else
	{
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.calls)
	{
		StatisticsCallsTableViewController *p = [[[StatisticsCallsTableViewController alloc] initWithCalls:self.calls] autorelease];
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
}

@end

/******************************************************************
 *
 *   StatisticsCellController
 *
 ******************************************************************/
#pragma mark StatisticsCellController
@interface StatisticsCellController : NSObject<TableViewCellController, StatisticsNumberCellDelegate>
{
	NSString *ps_title;
	int *ps_array;
	int ps_section;
	BOOL displayIfZero;
	int ps_timestamp;
	NSMutableDictionary *ps_adjustments;
	MTStatisticsAdjustment *adjustment;
	NSString *ps_adjustmentName;
	NSArray *calls;
	StatisticsTableViewController *delegate;
	int *ps_serviceYearValue;
}
@property (nonatomic, retain) MTStatisticsAdjustment *adjustment;
@property (nonatomic, assign) StatisticsTableViewController *delegate;
@property (nonatomic, retain) NSArray *calls;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) int *array;
@property (nonatomic, assign) int section;
@property (nonatomic, assign) BOOL displayIfZero;
@property (nonatomic, assign) int timestamp;
@property (nonatomic, assign) NSString *adjustmentName;
@end
@implementation StatisticsCellController
@synthesize adjustment;
@synthesize array = ps_array;
@synthesize section = ps_section;
@synthesize title = ps_title;
@synthesize timestamp = ps_timestamp;
@synthesize adjustmentName = ps_adjustmentName;
@synthesize displayIfZero;
@synthesize calls;
@synthesize delegate;

- (id)initWithTitle:(NSString *)title array:(int *)array section:(int)section timestamp:(int)timestamp adjustmentName:(NSString *)adjustmentName serviceYearValue:(int*)serviceYearValue
{
	if( (self = [super init]) )
	{
		self.title = title;
		self.array = array;
		self.section = section;
		self.timestamp = timestamp;
		self.adjustmentName = adjustmentName;
		ps_serviceYearValue = serviceYearValue;
	}
	return self;
}

- (void)dealloc
{
	self.calls = nil;
	self.title = nil;
	self.adjustment = nil;
	self.adjustmentName = nil;
	[super dealloc];
}

- (BOOL)isViewableWhenNotEditing
{
	return displayIfZero || self.array[self.section];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"StatisticsCellController";
	StatisticsNumberCell *cell = (StatisticsNumberCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		// Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"StatisticsNumberCell" bundle:nil];
		// Grab a pointer to the custom cell.
        cell = (StatisticsNumberCell *)temporaryController.view;
		// Release the temporary UIViewController.
        [temporaryController autorelease];
	}
	// quick way to make sure that the months were getting calculated correctly
//	cell.backgroundColor = ps_serviceYearValue ? [UIColor redColor] : [UIColor whiteColor];

	cell.nameLabel.text = self.title;
	cell.delegate = self;
	cell.statistic = self.array[self.section];
	if(self.calls)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;	
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	return cell;
}

- (MTStatisticsAdjustment *)adjustmentForTimestamp:(int)stamp
{
	MTUser *currentUser = [MTUser currentUser];
	NSManagedObjectContext *moc = currentUser.managedObjectContext;
	NSArray *adjustments = [moc fetchObjectsForEntityName:[MTStatisticsAdjustment entityName] 
											withPredicate:@"user == %@ && timestamp = %u && type == %@", currentUser, stamp, self.adjustmentName];
	MTStatisticsAdjustment *it;
	if(adjustments.count > 1)
	{
		// just in case they have more than one adjustment, fix it (this was a bug in the beta testing)
		it = [adjustments objectAtIndex:0];
		for(MTStatisticsAdjustment *entry in adjustments)
		{
			if(entry != it)
			{
				it.adjustmentValue += entry.adjustmentValue;
				[it.managedObjectContext deleteObject:entry];
			}
		}
	}
	else
	{
		it = [adjustments lastObject];
	}
	
	if(it == nil)
	{
		it = [MTStatisticsAdjustment insertInManagedObjectContext:moc];
		it.user = currentUser;
		it.timestampValue = stamp;
		it.type = self.adjustmentName;
		it.adjustmentValue = 0;
	}
	
	return it;
}

- (MTStatisticsAdjustment *)adjustment
{
	if(adjustment)
		return adjustment;

	adjustment = [self adjustmentForTimestamp:self.timestamp];
	[adjustment retain];
	return adjustment;
}

- (void)setStatisticsAdjustment:(MTStatisticsAdjustment *)theAdjustment difference:(int)difference andChange:(int)change
{
	if(ps_serviceYearValue)
		*ps_serviceYearValue += change;
	
	theAdjustment.adjustmentValue = difference;
	NSError *error = nil;
	if(![theAdjustment.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
	}
}

- (void)statisticsNumberCellValueChanged:(StatisticsNumberCell *)cell
{
	int value = self.adjustment.adjustmentValue;
	int difference = value + cell.statistic - self.array[self.section];
	int change = cell.statistic - self.array[self.section];
	self.array[self.section] = cell.statistic;

	[self setStatisticsAdjustment:self.adjustment difference:difference andChange:change];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.calls && !tableView.editing)
	{
		return indexPath;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.calls && !tableView.editing)
	{
		StatisticsCallsTableViewController *p = [[[StatisticsCallsTableViewController alloc] initWithCalls:self.calls] autorelease];
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
}


@end

/******************************************************************
 *
 *   HourStatisticsCellController
 *
 ******************************************************************/
#pragma mark HourStatisticsCellController
@interface HourStatisticsCellController : StatisticsCellController <HourPickerViewControllerDelegate, UIActionSheetDelegate>
{
	BOOL enableRounding;
}
@property (nonatomic, assign) BOOL enableRounding;
@end
@implementation HourStatisticsCellController
@synthesize enableRounding;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"HourStatisticsCellController";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	cell.selectionStyle = tableView.editing ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	cell.textLabel.text = self.title;
	int hours = self.array[self.section] / 60;
	int minutes = self.array[self.section] % 60;
	if(hours && minutes)
		cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
	else if(hours)
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
	else if(minutes)
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
	else
		cell.detailTextLabel.text = @"0";

	if(minutes && enableRounding)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing || enableRounding)
	{
		return indexPath;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		// make the new call view 
		HourPickerViewController *p = [[[HourPickerViewController alloc] initWithTitle:NSLocalizedString(@"Enter Hours", @"This is the title for the Statistics->Edit->Select an hours row-> view that pops up to allow you to edit the hours") minutes:self.array[self.section]] autorelease];
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else
	{
		int hours = self.array[self.section] / 60;
		int minutes = self.array[self.section] % 60;
		if(enableRounding && minutes)
		{
			[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
			int month = self.timestamp % 100;
			NSString *monthName = [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""];
			
			// handle rolling over minutes
			UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Would you like to move %d minutes from the month of %@ to the next month? Or, round up to %d hours for %@?\n(This will change the time that you put in the Hours view so you can undo this manually)", @"If the publisher has 1 hour 14 minutes, this question shows up in the statistics view if they click on the hours for a month, this question is asking them if they want to round up or roll over the minutes"), minutes, monthName, (hours+1), monthName]
																	 delegate:self
															cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
													   destructiveButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"Round Up to %d hours", @"Yes round up where %d is a placeholder for the number of hours"), hours+1]
															otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Move to next month", @"Yes roll over the extra minutes to the next month where %d is the placeholder for the number of minutes"), minutes], nil] autorelease];
			// 0: grey with grey and black buttons
			// 1: black background with grey and black buttons
			// 2: transparent black background with grey and black buttons
			// 3: grey transparent background
			alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
			[alertSheet showInView:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
			
		}
	}
}

- (void)hourPickerViewControllerDone:(HourPickerViewController *)hourPickerViewController
{
	int value = self.adjustment.adjustmentValue;
	int difference = value + hourPickerViewController.minutes - self.array[self.section];
	int change = hourPickerViewController.minutes - self.array[self.section];
	self.array[self.section] = hourPickerViewController.minutes;
	
	[self setStatisticsAdjustment:self.adjustment difference:difference andChange:change];
	[[self.delegate navigationController] popViewControllerAnimated:YES];
}
		   
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	//	[sheet dismissAnimated:YES];
	
	switch(button)
	{
		case 0: // ROUND UP
		{
			int minutes = self.array[self.section] % 60;
			
			// take off the minutes off of this month
			int value = self.adjustment.adjustmentValue;
			int difference = value - minutes + 60; // take off the minutes and add an hour
			int change = 60 - minutes;
			self.array[self.section] = self.array[self.section] - minutes + 60;			
			[self setStatisticsAdjustment:self.adjustment difference:difference andChange:change];
			
			[self.delegate updateAndReload];
			break;
		}
			
		case 1: // MOVE TO NEXT MONTH
		{
			int minutes = self.array[self.section] % 60;
			
			// take off the minutes off of this month
			int value = self.adjustment.adjustmentValue;
			int difference = value - minutes;
			self.array[self.section] = self.array[self.section] - minutes;			
			[self setStatisticsAdjustment:self.adjustment difference:difference andChange:0];
			
			// now move it to the next month
			int year = self.timestamp/100;
			int month = self.timestamp%100 + 1;
			if(month > 12)
			{
				month = 1;
				year++;
			}
			
			MTStatisticsAdjustment *newAdjustment = [self adjustmentForTimestamp:(month + year*100)];
			value = newAdjustment.adjustmentValue;
			[self setStatisticsAdjustment:newAdjustment difference:(value + minutes) andChange:0];
			
			[self.delegate updateAndReload];
			break;
		}
	}
}

@end


@implementation StatisticsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]) )
	{
		self.title = NSLocalizedString(@"Statistics", @"'Statistics' ButtonBar View text and Statistics View Title");
		self.tabBarItem.image = [UIImage imageNamed:@"statistics.png"];
	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
	// force the tableview to load if there was display information stored
	self.forceReload = YES;

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	MTSettings *settings = [MTSettings settings];
	if(!settings.statisticsAlertSheetShownValue)
	{
		settings.statisticsAlertSheetShownValue = YES;
		
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"This will show you your tabulated end of the month field service activity including:\nHours\nBooks\nBrochures\nMagazines\nStudies\n Please note that you will only see items that you have counts for.", @"This is a note displayed when they first see the Statistics View");
		[alertSheet show];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result 
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Compose Mail/SMS

- (NSString *)generateMessageBodyUsingHtml:(BOOL)useHtml monthNames:(NSArray *)monthNames selectedMonths:(NSArray *)selectedMonths  
{
	MTUser *currentUser = [MTUser currentUser];
	NSMutableString *string = [[[NSMutableString alloc] init] autorelease];
	if(useHtml)
	{
		[string appendString:@"<html><body>"];
	}
	NSString *crString = useHtml ? @"<br>" : @"\n";
	NSString *notes = currentUser.secretaryEmailNotes;
	if([notes length])
	{
		if(useHtml)
		{
			notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
			notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
		}
		[string appendString:notes];
		[string appendFormat:@"%@%@", crString, crString];
	}
	
	BOOL first = YES;
	for(int index = 0; index < [selectedMonths count]; ++index)
	{
		if([[selectedMonths objectAtIndex:index] boolValue])
		{
			if(!first)
			{
				[string appendFormat:@"%@%@", crString, crString];
			}
			first = NO;
			NSString *title = [NSString stringWithFormat:NSLocalizedString(@"%@ Field Service Activity Report:<br>", @"Text used in the email that is sent to the congregation secretary, the <br> you see in the text are RETURN KEYS so that you can space multiple months apart from eachother"), [monthNames objectAtIndex:index]];
			if(useHtml)
			{
				[string appendString:@"<h3>"];
				[string appendString:title];
				[string appendString:@"</h3>"];
			}
			else
			{
				[string appendString:[title stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"]];
			}
			// BOOKS
			[string appendString:[NSString stringWithFormat:@"%@: %d%@", NSLocalizedString(@"Books", @"Publication Type name"), _books[index], crString]];
			// BROCHURES
			[string appendString:[NSString stringWithFormat:@"%@: %d%@", NSLocalizedString(@"Brochures", @"Publication Type name"), _brochures[index], crString]];
			// HOURS
			NSString *count = @"0";
			int hours = _minutes[index] / 60;
			int minutes = _minutes[index] % 60;
			if(hours && minutes)
				count = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
			else if(hours)
				count = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
			else if(minutes)
				count = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
			[string appendString:[NSString stringWithFormat:@"%@: %@%@", NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view"), count, crString]];
			
			// MAGAZINES
			[string appendString:[NSString stringWithFormat:@"%@: %d%@", NSLocalizedString(@"Magazines", @"Publication Type name"), _magazines[index], crString]];
			// RETURN VISITS
			[string appendString:[NSString stringWithFormat:@"%@: %d%@", NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View"), _returnVisits[index], crString]];
			// STUDIES
			[string appendString:[NSString stringWithFormat:@"%@: %d%@", NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View"), _bibleStudies[index], crString]];
			// CAMPAIGN TRACTS
			if(_campaignTracts[index])
				[string appendString:[NSString stringWithFormat:@"%@: %d%@", NSLocalizedString(@"Campaign Tracts", @"Publication Type name"), _campaignTracts[index], crString]];
			// QUICKBUILD TIME
			if(_quickBuildMinutes[index])
			{
				count = @"0";
				int hours = _quickBuildMinutes[index] / 60;
				int minutes = _quickBuildMinutes[index] % 60;
				if(hours && minutes)
					count = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
				else if(hours)
					count = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
				else if(minutes)
					count = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
				[string appendString:[NSString stringWithFormat:@"%@: %@%@", NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds"), count, crString]];
			}
		}
	}
	
	if(useHtml)
	{
		[string appendString:@"</body></html>"];
	}
	return string;
}

// Displays an SMS composition interface inside the application. 
-(void)sendSmsUsingMonthNames:(NSArray *)monthNames selectedMonths:(NSArray *)selectedMonths  
{
	// add notes if there are any
	MTUser *currentUser = [MTUser currentUser];

	NSString *telephoneNumber = currentUser.secretaryTelephoneNumber;
	if(telephoneNumber)
	{
		// remove invalid characters and formatting before calling
		unichar one;
		NSMutableString *parsedValue = [NSMutableString string];
		int length = [telephoneNumber length];
		for(int i = 0; i < length; i++)
		{
			one = [telephoneNumber characterAtIndex:i];
			if(isdigit(one) || one == '+' || one == ',' || one == '*' || one == ' ')
			{
				[parsedValue appendFormat:@"%c", one];
			}
		}
		telephoneNumber = parsedValue;
	}		
	if(telephoneNumber == nil || telephoneNumber.length == 0)
		return;
	
	MFMessageComposeViewController *messageView = [[[MFMessageComposeViewController alloc] init] autorelease];
	if(telephoneNumber && telephoneNumber.length)
	{
		[messageView setRecipients:[telephoneNumber componentsSeparatedByString:@" "]];
	}
	
	messageView.body = [self generateMessageBodyUsingHtml:NO monthNames:monthNames selectedMonths:selectedMonths];
	messageView.messageComposeDelegate = self;
	[self.navigationController presentModalViewController:messageView animated:YES];
}

- (void)sendEmailUsingMonthNames:(NSArray *)monthNames selectedMonths:(NSArray *)selectedMonths  
{
	// add notes if there are any
	MTUser *currentUser = [MTUser currentUser];
	NSString *emailAddress = currentUser.secretaryEmailAddress;
	if(emailAddress == nil || emailAddress.length == 0)
		return;
	
	if([MFMailComposeViewController canSendMail] == NO)
	{
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		alertSheet.title = NSLocalizedString(@"You must setup email on this device to be able to send an email.  Open the Mail application and setup your email account", @"This is a message displayed when the user does not have email setup on their iDevice");
		[alertSheet show];
		return;
	}
	
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"Field Service Activity Report", @"Subject text for the email that is sent for the Field Service Activity report")];
	if(emailAddress && emailAddress.length)
	{
		[mailView setToRecipients:[emailAddress componentsSeparatedByString:@" "]];
	}
	
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	

	[mailView setMessageBody:[self generateMessageBodyUsingHtml:YES monthNames:monthNames selectedMonths:selectedMonths] isHTML:YES];
	[string release];
	[mailView setMailComposeDelegate:self];
	[self.navigationController presentModalViewController:mailView animated:YES];
	
}

- (void)sendReportUsingMonthNames:(NSArray *)monthNames selectedMonths:(NSArray *)selectedMonths  
{
	MTUser *currentUser = [MTUser currentUser];
	if(isSmsAvaliable() && currentUser.sendReportUsingSmsValue)
	{
		[self sendSmsUsingMonthNames:monthNames selectedMonths:selectedMonths];
	}
	else
	{
		[self sendEmailUsingMonthNames:monthNames selectedMonths:selectedMonths];
	}
}

- (void)monthChooserViewControllerSendEmail:(MonthChooserViewController *)monthChooserViewController
{
	NSString *emailAddress = monthChooserViewController.emailAddress.textField.text;
	MTUser *currentUser = [MTUser currentUser];
	if(isSmsAvaliable() && currentUser.sendReportUsingSmsValue)
	{
		currentUser.secretaryTelephoneNumber = emailAddress;
	}
	else
	{
		currentUser.secretaryEmailAddress = emailAddress;
	}

	NSError *error = nil;
	if(![currentUser.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.navigationController error:error];
	}
	
	NSArray *selectedMonths = monthChooserViewController.selected;
	NSArray *monthNames = monthChooserViewController.months;
	
	[self sendReportUsingMonthNames:monthNames selectedMonths:selectedMonths];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	//	[sheet dismissAnimated:YES];
	
	if(_emailActionSheet)
	{
		if(button == 0)
		{
			int month = _thisMonth;
			NSMutableArray *months = [NSMutableArray array];
			int i;
			for(i = 0; i < 12; ++i)
			{
				if(month < 1)
					month = 12 + month;
				[months addObject:[[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
				
				--month;
			}
			
			MonthChooserViewController *p = [[[MonthChooserViewController alloc] initWithMonths:months] autorelease];
			p.delegate = self;
			
			[[self navigationController] pushViewController:p animated:YES];		
		}
		else if(button == 1 && actionSheet.numberOfButtons > 2)
		{
			int month = _thisMonth;
			NSMutableArray *months = [NSMutableArray array];
			int i;
			for(i = 0; i < 12; ++i)
			{
				if(month < 1)
					month = 12 + month;
				[months addObject:[[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
				
				--month;
			}
			
			// use the current month unless it is over the 6th day of the month
			int monthGuess = 0;
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:[NSDate date]];
			
			if([dateComponents day] <= 6)
			{
				monthGuess = 1;
			}
			NSMutableArray *array = [NSMutableArray array];
			for(int i = 0; i < 12; i++)
			{
				[array addObject:[NSNumber numberWithBool:(monthGuess == i)]];
			}
			[self sendReportUsingMonthNames:months selectedMonths:array];
		}
	}
	else
	{
#if 0
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
		switch(button)
		{
			case 0: // ROUND UP
			{
				int minutes = _minutes[_selectedMonth] % 60;
				
				NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
				[comps setMonth:-_selectedMonth];
				NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
				
				// now go and add the entry
				NSMutableDictionary *timeEntry = [NSMutableDictionary dictionary];
				[timeEntry setObject:date forKey:SettingsTimeEntryDate];
				[timeEntry setObject:[NSNumber numberWithInt:(60 - minutes)] forKey:SettingsTimeEntryMinutes];
				[[[[Settings sharedInstance] userSettings] objectForKey:SettingsTimeEntries] addObject:timeEntry];
				[[Settings sharedInstance] saveData];
				[self updateAndReload];
				break;
			}
				
			case 1: // MOVE TO NEXT MONTH
			{
				int minutes = _minutes[_selectedMonth] % 60;
				
				NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
				[comps setMonth:(1 - _selectedMonth)];
				NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
				
				//make the time entries editable
				NSMutableArray *timeEntries = [[[Settings sharedInstance] userSettings] objectForKey:SettingsTimeEntries];
				if(timeEntries == nil)
				{
					timeEntries = [NSMutableArray array];
					[[[Settings sharedInstance] userSettings] setObject:timeEntries forKey:SettingsTimeEntries];
				}
				// now go and add the entry
				NSMutableDictionary *timeEntry = [NSMutableDictionary dictionary];
				[timeEntry setObject:date forKey:SettingsTimeEntryDate];
				[timeEntry setObject:[NSNumber numberWithInt:minutes] forKey:SettingsTimeEntryMinutes];
				[timeEntries addObject:timeEntry];
				[[Settings sharedInstance] saveData];
				
				
				int month = _thisMonth - _selectedMonth;
				int year = _thisYear;
				if(month < 1)
				{
					--year;
					month += 12;
				}
				
				// now remove time from an entry in this month
				int timeCount = [timeEntries count];
				int timeIndex;
				for(timeIndex = 0; timeIndex < timeCount; ++timeIndex)
				{
					timeEntry = [timeEntries objectAtIndex:timeIndex];
					
					NSDate *date = [timeEntry objectForKey:SettingsTimeEntryDate];	
					NSNumber *minutesEntry = [timeEntry objectForKey:SettingsTimeEntryMinutes];
					if(date && minutesEntry)
					{
						NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
						if(month == [dateComponents month] && year == [dateComponents year])
						{
							// get the minimum of the two
							int leftover = [minutesEntry intValue] < minutes ? [minutesEntry intValue] : minutes;
							
							NSMutableDictionary *newTimeEntry = [NSMutableDictionary dictionary];
							[newTimeEntry setObject:date forKey:SettingsTimeEntryDate];
							[newTimeEntry setObject:[NSNumber numberWithInt:([minutesEntry intValue] - leftover)] forKey:SettingsTimeEntryMinutes];
							[timeEntries replaceObjectAtIndex:timeIndex withObject:newTimeEntry];
							// subtract off what we were able to take off of this time entry
							// if it turns out that it was not enough, then we will try another entry
							minutes -= leftover;
							if(minutes == 0)
							{
								[[Settings sharedInstance] saveData];
								// we have finished subtracting minutes off of time entries
								break;
							}
						}
					}
				}
				
				
				[self updateAndReload];
				break;
			}
		}
#endif
	}
}

- (void)navigationControlEmail:(id)sender
{
	int month = _thisMonth;
	NSMutableArray *months = [NSMutableArray array];
	int i;
	for(i = 0; i < 12; ++i)
	{
		if(month < 1)
			month = 12 + month;
		[months addObject:[[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
		
		--month;
	}
	
	// use the current month unless it is over the 6th day of the month
	NSString *monthGuess = [months objectAtIndex:0];
    // initalize the data to the current date
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:[NSDate date]];
	
	if([dateComponents day] <= 6)
	{
		monthGuess = [months objectAtIndex:1];
	}	
	UIActionSheet *actionSheet;
	MTUser *currentUser = [MTUser currentUser];
	
	if([currentUser.secretaryEmailAddress length])
	{
		actionSheet = [[[UIActionSheet alloc] initWithTitle:@""
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
								     destructiveButtonTitle:nil
										  otherButtonTitles:NSLocalizedString(@"Pick Months To Send", @"Statistics button to allow you to pick months to send to the congregation secretary")
						,[NSString stringWithFormat:NSLocalizedString(@"Send %@ Report", @"This is text used in the statistics view where you click on the 'ActionSheet' button and it asks you what you want to do to send your congregation secretary your statistics where %@ is the placeholder for the month"), monthGuess]
						,nil] autorelease];
	}
	else
	{
		actionSheet = [[[UIActionSheet alloc] initWithTitle:@""
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
									 destructiveButtonTitle:nil
										  otherButtonTitles:NSLocalizedString(@"Pick Months To Send", @"Statistics button to allow you to pick months to send to the congregation secretary")
						,nil] autorelease];
	}
	_emailActionSheet = YES;
	// 0: grey with grey and black buttons
	// 1: black background with grey and black buttons
	// 2: transparent black background with grey and black buttons
	// 3: grey transparent background
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
	
}

- (void)displayButtons
{
	if(self.editing)
	{
		// update the button in the nav bar
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				 target:self
																				 action:@selector(navigationControlDone:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:YES];
		[self.navigationItem setLeftBarButtonItem:nil animated:YES];
		
		// hide the back button so that they cant cancel the edit without hitting done
		self.navigationItem.hidesBackButton = YES;
	}
	else
	{
		// update the button in the nav bar
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																				 target:self
																				 action:@selector(navigationControlEdit:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:YES];
		// update the button in the nav bar
		button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																target:self
																action:@selector(navigationControlEmail:)] autorelease];
		[self.navigationItem setLeftBarButtonItem:button animated:YES];
	}

}

- (void)navigationControlEdit:(id)sender 
{
	self.editing = YES;
	[self displayButtons];
}	

- (void)navigationControlDone:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
	self.editing = NO;
	[self displayButtons];
}	

- (void)loadView 
{
	[super loadView];
	
	[self displayButtons];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)computeStatisticsDeletingOldEntries:(BOOL)deleteOldEntries
{
	memset(_books, 0, sizeof(_books));
	memset(_brochures, 0, sizeof(_brochures));
	memset(_minutes, 0, sizeof(_minutes));
	memset(_magazines, 0, sizeof(_magazines));
	memset(_returnVisits, 0, sizeof(_returnVisits));
	memset(_bibleStudies, 0, sizeof(_bibleStudies));
	memset(_campaignTracts, 0, sizeof(_campaignTracts));
	memset(_quickBuildMinutes, 0, sizeof(_quickBuildMinutes));
	
	for(int i = 0; i < kMonthsShown; i++)
	{
		[_individualCalls[i] release];
		_individualCalls[i] = nil;
	}
	_serviceYearBooks = 0;
	_serviceYearBrochures = 0;
	_serviceYearMinutes = 0;
	_serviceYearQuickBuildMinutes = 0;
	_serviceYearMagazines = 0;
	_serviceYearReturnVisits = 0;
	_serviceYearBibleStudies = 0;
	_serviceYearStudyIndividuals = 0;
	_serviceYearCampaignTracts = 0;
	[_serviceYearStudyIndividualCalls release];
	_serviceYearStudyIndividualCalls = [[NSMutableArray alloc] init];
	
	
	MTUser *currentUser = [MTUser currentUser];
	NSManagedObjectContext *moc = currentUser.managedObjectContext;

	int pioneerStartTimestamp = 0;
	if(currentUser.pioneerStartDate != nil)
	{
		NSDateComponents *pioneerStartDateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:currentUser.pioneerStartDate];
		pioneerStartTimestamp = [pioneerStartDateComponents year] * 100 + [pioneerStartDateComponents month];
	}

	NSDateComponents *startOfDataCollectionComponents = [[[NSDateComponents alloc] init] autorelease];
	[startOfDataCollectionComponents setMonth:_thisMonth];
	[startOfDataCollectionComponents setYear:_thisYear - 1];
	int startOfDataCollectionTimestamp = (_thisYear - 1) * 100 + _thisMonth;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDate *startOfDataCollection = [gregorian dateFromComponents:startOfDataCollectionComponents];
	
	int nextMonth = _thisMonth == 12 ? 1 : _thisMonth + 1;
	int nextMonthsYear = _thisMonth == 12 ? _thisYear + 1 : _thisYear;
	int endOfDataCollectionTimestamp = nextMonthsYear * 100 + nextMonth;
	NSDateComponents *endOfDataCollectionComponents = [[[NSDateComponents alloc] init] autorelease];
	[endOfDataCollectionComponents setMonth:nextMonth];
	[endOfDataCollectionComponents setYear:nextMonthsYear];
	NSDate *endOfDataCollection = [gregorian dateFromComponents:endOfDataCollectionComponents];
	
	BOOL newServiceYear = _thisMonth >= 9;
	
	//Start with Adjustments
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSArray *adjustments = [moc fetchObjectsForEntityName:[MTStatisticsAdjustment entityName]
												withPredicate:@"user == %@ && timestamp > %u && timestamp < %u", currentUser, startOfDataCollectionTimestamp, endOfDataCollectionTimestamp];
		
		for(MTStatisticsAdjustment *adjustment in adjustments)
		{
			NSString *key = adjustment.type;
			int dummyArray[kMonthsShown];
			int *array = dummyArray;
			int *serviceYearValue;
			
			if([key isEqualToString:StatisticsTypeHours])
			{
				array = _minutes;
				serviceYearValue = &_serviceYearMinutes;
			}
			else if([key isEqualToString:StatisticsTypeBooks])
			{
				array = _books;
				serviceYearValue = &_serviceYearBooks;
			}
			else if([key isEqualToString:StatisticsTypeBrochures])
			{
				array = _brochures;
				serviceYearValue = &_serviceYearBrochures;
			}
			else if([key isEqualToString:StatisticsTypeMagazines])
			{
				array = _magazines;
				serviceYearValue = &_serviceYearMagazines;
			}
			else if([key isEqualToString:StatisticsTypeReturnVisits])
			{
				array = _returnVisits;
				serviceYearValue = &_serviceYearReturnVisits;
			}
			else if([key isEqualToString:StatisticsTypeBibleStudies])
			{
				array = _bibleStudies;
				serviceYearValue = &_serviceYearBibleStudies;
			}
			else if([key isEqualToString:StatisticsTypeCampaignTracts])
			{
				array = _campaignTracts;
				serviceYearValue = &_serviceYearCampaignTracts;
			}
			else if([key isEqualToString:StatisticsTypeRBCHours])
			{
				array = _quickBuildMinutes;
				serviceYearValue = &_serviceYearQuickBuildMinutes;
			}
			assert(array);// you should handle this
			assert(serviceYearValue);// you should handle this

			int timestamp = adjustment.timestampValue;
			int month = timestamp % 100;
			int year = timestamp / 100;

			int offset = -1;
			if(year == _thisYear && 
			   month <= _thisMonth)
			{
				offset = _thisMonth - month;
			}
			else if(year == _thisYear - 1 &&
					month > _thisMonth)
			{
				offset = 12 - month + _thisMonth;
			}
			if(offset < 0 || offset > 11)
				continue;

			int value = adjustment.adjustmentValue;
			if(value == 0)
				continue;
			
			array[offset] += value;
						
			if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
			   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
			{
				if(pioneerStartTimestamp <= adjustment.timestampValue)
				{
					*serviceYearValue += value;
				}
			}
		}
		[pool drain];
	}
	
	// Hours entries
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSArray *timeEntries = [moc fetchObjectsForEntityName:[MTTimeEntry entityName]
												withPredicate:@"type == %@ && date > %@ && date < %@", [MTTimeType hoursTypeForUser:currentUser], startOfDataCollection, endOfDataCollection];
		
		for(MTTimeEntry *timeEntry in timeEntries)
		{
			NSDate *date = timeEntry.date;	
			int minutes = timeEntry.minutesValue;
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
			int month = [dateComponents month];
			int year = [dateComponents year];
			int timestamp = year * 100 + month;
			int offset = -1;
			if(year == _thisYear && 
			   month <= _thisMonth)
			{
				offset = _thisMonth - month;
			}
			else if(year == _thisYear - 1 &&
					month > _thisMonth)
			{
				offset = 12 - month + _thisMonth;
			}
			if(offset < 0 || offset > 11)
				continue;
			
			// we found a valid month
			_minutes[offset] += minutes;
			
			if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
			   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
			{
				if(pioneerStartTimestamp <= timestamp)
				{
                    _serviceYearMinutes += minutes;
				}
			}
		}
		[pool drain];
	}

	// QUICK BUILD
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSArray *timeEntries = [moc fetchObjectsForEntityName:[MTTimeEntry entityName]
												withPredicate:@"type == %@ && date > %@ && date < %@", [MTTimeType rbcTypeForUser:currentUser], startOfDataCollection, endOfDataCollection];
		
		for(MTTimeEntry *timeEntry in timeEntries)
		{
			NSDate *date = timeEntry.date;	
			int minutes = timeEntry.minutesValue;
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
			int month = [dateComponents month];
			int year = [dateComponents year];
			int timestamp = year * 100 + month;
			
			int offset = -1;
			if(year == _thisYear && 
			   month <= _thisMonth)
			{
				offset = _thisMonth - month;
			}
			// if this call was made last year and in a month after this month
			else if(year == _thisYear - 1 &&
					_thisMonth < month)
			{
				offset = 12 - month + _thisMonth;
			}
			if(offset < 0 || offset > 11)
				continue;
			
			_quickBuildMinutes[offset] += minutes;
			
			// newServiceYear means that the months that are added are above the current month
			if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
			   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
			{
				if(pioneerStartTimestamp <= timestamp)
				{
                    _serviceYearQuickBuildMinutes += minutes;
                }
			}
		}
		[pool drain];
	}	
	
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSArray *bulkPlacementPublications = [moc fetchObjectsForEntityName:[MTPublication entityName]
														  propertiesToFetch:[NSArray arrayWithObjects:@"type", @"count", nil]
														withSortDescriptors:nil
															  withPredicate:@"bulkPlacement.user == %@ && bulkPlacement.date > %@ && bulkPlacement.date < %@", currentUser, startOfDataCollection, endOfDataCollection];
		
		
		for(MTPublication *publication in bulkPlacementPublications) // ASSIGNMENT, NOT COMPARISON 
		{
			NSDate *date = publication.bulkPlacement.date;
			int offset = -1;
			
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
			int month = [dateComponents month];
			int year = [dateComponents year];
            int timestamp = year * 100 + month;

			if(year == _thisYear && 
			   month <= _thisMonth)
			{
				offset = _thisMonth - month;
			}
			// if this call was made last year and in a month after this month
			else if(year == _thisYear - 1 &&
					_thisMonth < month)
			{
				offset = 12 - month + _thisMonth;
			}
			
			if(offset >= 0)
			{
				int number = publication.countValue;
				NSString *type = publication.type;
				if(type != nil)
				{
					if([type isEqualToString:PublicationTypeBook] || 
					   [type isEqualToString:PublicationTypeDVDBible] || 
					   [type isEqualToString:PublicationTypeDVDBook])
					{
						_books[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearBooks += number;
                            }
						}
					}
					else if([type isEqualToString:PublicationTypeBrochure] || 
							[type isEqualToString:PublicationTypeDVDBrochure])
					{
						_brochures[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearBrochures += number;
                            }
						}
					}
					else if([type isEqualToString:PublicationTypeMagazine])
					{
						_magazines[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearMagazines += number;
                            }
						}
					}
					else if([type isEqualToString:PublicationTypeTwoMagazine])
					{
						_magazines[offset] += number*2;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearMagazines += number*2;
                            }
						}
					}
					else if([type isEqualToString:PublicationTypeCampaignTract])
					{
						_campaignTracts[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearCampaignTracts += number;
                            }
						}
					}
				}
				
			}
		}
		[pool drain];
	}
	
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSMutableArray *studies = [NSMutableArray arrayWithObjects:[NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], nil];
		NSMutableArray *tempServiceYearStudies = [NSMutableArray arrayWithObjects:[NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], [NSMutableSet set], nil];
		NSArray *returnVisits = [moc fetchObjectsForEntityName:[MTReturnVisit entityName]
												 withPredicate:@"call.user == %@ && date > %@ && date < %@", currentUser, startOfDataCollection, endOfDataCollection];
		
		for(MTReturnVisit *returnVisit in returnVisits)
		{
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:returnVisit.date];
			int month = [dateComponents month];
			int year = [dateComponents year];
            int timestamp = year * 100 + month;

			int offset = -1;
			
			if(year == _thisYear && 
			   month <= _thisMonth)
			{
				offset = _thisMonth - month;
			}
			// if this call was made last year and in a month after this month
			else if(year == _thisYear - 1 &&
					_thisMonth < month)
			{
				offset = 12 - month + _thisMonth;
			}
			
			// this month's information should not be counted
			if(offset < 0 || offset > 11)
				continue;
			
			NSString *type = returnVisit.type;
			BOOL isStudy = [type isEqualToString:CallReturnVisitTypeStudy];
			BOOL isReturnVisit = isStudy || [type isEqualToString:CallReturnVisitTypeReturnVisit];
			BOOL isTransfer = [type isEqualToString:CallReturnVisitTypeTransferedStudy] ||
								[type isEqualToString:CallReturnVisitTypeTransferedInitialVisit] ||
								[type isEqualToString:CallReturnVisitTypeTransferedReturnVisit] ||
								[type isEqualToString:CallReturnVisitTypeTransferedNotAtHome];
			
			if(isReturnVisit)
			{
				_returnVisits[offset]++;
				if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
				   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
				{
                    if(pioneerStartTimestamp <= timestamp)
                    {
                        _serviceYearReturnVisits++;
                    }
				}
			}
			
			if(isStudy)
			{
				[[studies objectAtIndex:offset] addObject:returnVisit.call];
                if(pioneerStartTimestamp <= timestamp)
                {
                    [[tempServiceYearStudies objectAtIndex:offset] addObject:returnVisit.call];
                }
			}
			
			if(!isTransfer)
			{
				for(MTPublication *publication in returnVisit.publications)
				{
					NSString *type = publication.type;
					
					if([type isEqualToString:PublicationTypeBook] ||
					   [type isEqualToString:PublicationTypeDVDBible] || 
					   [type isEqualToString:PublicationTypeDVDBook])
					{
						_books[offset]++;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearBooks++;
                            }
						}
					}
					else if([type isEqualToString:PublicationTypeBrochure] ||
							[type isEqualToString:PublicationTypeDVDBrochure])
					{
						_brochures[offset]++;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearBrochures++;
                            }
						}
					}
					else if([type isEqualToString:PublicationTypeMagazine])
					{
						_magazines[offset]++;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearMagazines++;
                            }
						}
					}
					else if([type isEqualToString:PublicationTypeTwoMagazine])
					{
						_magazines[offset] += 2;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearMagazines += 2;
                            }
						}
					}
					else if([type isEqualToString:PublicationTypeCampaignTract])
					{
						_campaignTracts[offset]++;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
                            if(pioneerStartTimestamp <= timestamp)
                            {
                                _serviceYearCampaignTracts++;
                            }
						}
					}
				}
			}
		}
		int offset = 0;
		for(NSSet *calls in studies)
		{
			int count = calls.count;
			if(count)
			{
				_bibleStudies[offset] += count;
				_individualCalls[offset] = (id)[[calls allObjects] retain];
			}
			offset++;
        }
        offset = 0;
		NSMutableSet *serviceYearStudies = [NSMutableSet set];
		for(NSSet *calls in tempServiceYearStudies)
        {
			int count = calls.count;
			if(count)
			{
				if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
				   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
				{
					_serviceYearBibleStudies += count;
					[serviceYearStudies unionSet:calls];
				}
			}
			offset++;
		}
		[_serviceYearStudyIndividualCalls setArray:[serviceYearStudies allObjects]];
		_serviceYearStudyIndividuals = [serviceYearStudies count];
		[pool drain];
	}
}

- (BOOL)showYearInformation
{
	NSString *type = [[MTUser currentUser] publisherType];
	return type == nil || 
	[type isEqualToString:PublisherTypePioneer] ||
	[type isEqualToString:PublisherTypeSpecialPioneer] ||
	[type isEqualToString:PublisherTypeTravelingServant];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	MTUser *currentUser = [MTUser currentUser];
	// save off this month and last month for quick compares
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:[NSDate date]];
	_thisMonth = [dateComponents month];
	_thisYear = [dateComponents year];
	
	_lastMonth = _thisMonth == 1 ? 12 : _thisMonth - 1;
	
	if(_thisMonth == 9)
	{
		// first *sigh* go through last service year and add up everything
		_thisMonth = 8;
		_lastMonth = 7;
		[self computeStatisticsDeletingOldEntries:NO];
		
		// then save everything that we care about off
		int serviceYearBooks = _serviceYearBooks;
		int serviceYearBrochures = _serviceYearBrochures;
		int serviceYearMinutes = _serviceYearMinutes;
		int serviceYearQuickBuildMinutes = _serviceYearQuickBuildMinutes;
		int serviceYearMagazines = _serviceYearMagazines;
		int serviceYearReturnVisits = _serviceYearReturnVisits;
		int serviceYearBibleStudies = _serviceYearBibleStudies;
		int serviceYearStudyIndividuals = _serviceYearStudyIndividuals;
		int serviceYearCampaignTracts = _serviceYearCampaignTracts;
		
		NSMutableArray *serviceYearStudyIndividualCalls = _serviceYearStudyIndividualCalls;
		_serviceYearStudyIndividualCalls = [[NSMutableArray alloc] init];
		
		// now recompute the statistics and then...
		_thisMonth = 9;
		_lastMonth = 8;
		[self computeStatisticsDeletingOldEntries:YES];
		
		// use the old service year numbers instead of the current service year
		_serviceYearBooks = serviceYearBooks;
		_serviceYearBrochures = serviceYearBrochures;
		_serviceYearMinutes = serviceYearMinutes;
		_serviceYearQuickBuildMinutes = serviceYearQuickBuildMinutes;
		_serviceYearMagazines = serviceYearMagazines;
		_serviceYearReturnVisits = serviceYearReturnVisits;
		_serviceYearBibleStudies = serviceYearBibleStudies;
		_serviceYearStudyIndividuals = serviceYearStudyIndividuals;
		_serviceYearCampaignTracts = serviceYearCampaignTracts;
		[_serviceYearStudyIndividualCalls release];
		_serviceYearStudyIndividualCalls = serviceYearStudyIndividualCalls;
		
		_serviceYearText = NSLocalizedString(@"Last Service Year Total", @"Last Service year total hours label");
	}
	else
	{
		_serviceYearText = NSLocalizedString(@"Service Year Total", @"Service year total hours label");
		[self computeStatisticsDeletingOldEntries:YES];
	}
	
	// Service Year Totals
	if([self showYearInformation])
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.isViewableWhenEditing = NO;
		sectionController.title = _serviceYearText;
		sectionController.editingTitle = sectionController.title;
		[self.sectionControllers addObject:sectionController];
		[sectionController release];

		// Hours
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")
																											serviceYearValue:&_serviceYearMinutes
																													 isHours:YES];
			cellController.displayIfZero = YES;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Books
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Books", @"Publication Type name") 
																											serviceYearValue:&_serviceYearBooks];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Brochures
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Brochures", @"Publication Type name") 
																											serviceYearValue:&_serviceYearBrochures];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Magazines
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Magazines", @"Publication Type name") 
																											serviceYearValue:&_serviceYearMagazines];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Return Visits
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View") 
																											serviceYearValue:&_serviceYearReturnVisits];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Bible Studies
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View") 
																											serviceYearValue:&_serviceYearBibleStudies];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Study Individuals
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Study Individuals", @"Bible Studies label on the Statistics View") 
																											serviceYearValue:&_serviceYearStudyIndividuals];
			cellController.calls = _serviceYearStudyIndividualCalls;
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Campaign Tracts
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name") 
																											serviceYearValue:&_serviceYearCampaignTracts];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// RBC Hours
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")
																											serviceYearValue:&_serviceYearQuickBuildMinutes
																													 isHours:YES];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}	

	// how many months do they want to show?
	int shownMonths = 2;
	NSNumber *value = currentUser.monthDisplayCount;
	if(value)
		shownMonths = [value intValue];
	
	// figure out the timestamp to compare the month/year with
	// we are only comparing serviceYearTimeStampStart < timestamp because we dont want to include september in the counts.
	// the month of september displays last service year only
	int serviceYearTimestampStart;
	if(_thisMonth >= 9)
		serviceYearTimestampStart = _thisYear * 100 + 9;
	else
		serviceYearTimestampStart = (_thisYear - 1) * 100 + 9;
	
	for(int section = 0; section < 12; section++)
	{
		NSString *title;
		int month = _thisMonth - section;
		int timestamp;
		BOOL affectServiceYear;
		
		if(_thisMonth == 9)
		{
			if(month < 1)
			{
				month = 12 + month;
				timestamp = (_thisYear - 1) * 100 + month;
			}
			else
			{
				timestamp = _thisYear * 100 + month;
			}
			// for september we want things < current september timestamp
			// J F M A M J J A S O N D
			
			affectServiceYear = timestamp < serviceYearTimestampStart;
		}
		else
		{
			// for october we want things > current september timestamp this year
			// J F M A M J J A S O N D
			
			// for january we want things > current september timestamp last year
			// J F M A M J J A S O N D
			
			if(month < 1)
			{
				month = 12 + month;
				timestamp = (_thisYear - 1) * 100 + month;
			}
			else
			{
				timestamp = _thisYear * 100 + month;
			}
			affectServiceYear = timestamp >= serviceYearTimestampStart;
		}

		title = [NSString stringWithFormat:NSLocalizedString(@"Time for %@", @"Time for %@ Group title on the Statistics View where %@ is the month of the year"), 
				 [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];

		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.title = title;
		sectionController.editingTitle = sectionController.title;
		sectionController.isViewableWhenNotEditing = section < shownMonths; // only show X number of months
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		// Hours
		{
			HourStatisticsCellController *cellController = [[HourStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")
																										 array:_minutes
																									   section:section
																									 timestamp:timestamp
																								adjustmentName:StatisticsTypeHours
																							  serviceYearValue:(affectServiceYear ? &_serviceYearMinutes : nil)];
			cellController.delegate = self;
			cellController.enableRounding = YES;
			cellController.displayIfZero = YES;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Books
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Books", @"Publication Type name")
																								 array:_books
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeBooks
																					  serviceYearValue:(affectServiceYear ? &_serviceYearBooks : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Brochures
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Brochures", @"Publication Type name")
																								 array:_brochures
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeBrochures
																					  serviceYearValue:(affectServiceYear ? &_serviceYearBrochures : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Magazines
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Magazines", @"Publication Type name")
																								 array:_magazines
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeMagazines
																					  serviceYearValue:(affectServiceYear ? &_serviceYearMagazines : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Return Visits
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")
																								 array:_returnVisits
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeReturnVisits
																					  serviceYearValue:(affectServiceYear ? &_serviceYearReturnVisits : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Bible Studies
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")
																								 array:_bibleStudies
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeBibleStudies
																					  serviceYearValue:(affectServiceYear ? &_serviceYearBibleStudies : nil)];
			cellController.calls = _individualCalls[section];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Campaign Tracts
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name") 
																								 array:_campaignTracts
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeCampaignTracts
																					  serviceYearValue:(affectServiceYear ? &_serviceYearCampaignTracts : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// RBC Hours
		{
			HourStatisticsCellController *cellController = [[HourStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")
																										 array:_quickBuildMinutes
																									   section:section
																									 timestamp:timestamp
																								adjustmentName:StatisticsTypeRBCHours
																							  serviceYearValue:(affectServiceYear ? &_serviceYearQuickBuildMinutes : nil)];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}
}


@end
