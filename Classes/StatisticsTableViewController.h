//
//  StatisticsTableViewController.h
//  MyTime
//
//  Created by Brent Priddy on 4/9/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MonthChooserViewController.h"

#define kMonthsShown 12

@interface StatisticsTableViewController : GenericTableViewController <MonthChooserViewControllerDelegate,
                                                                       UIActionSheetDelegate,
                                                                       MFMailComposeViewControllerDelegate> 
{
	int _serviceYearBooks;
	int _serviceYearBrochures;
	int _serviceYearMinutes;
	int _serviceYearQuickBuildMinutes;
	int _serviceYearMagazines;
	int _serviceYearReturnVisits;
	int _serviceYearBibleStudies;
	int _serviceYearStudyIndividuals;
	int _serviceYearCampaignTracts;
	
	NSMutableArray *_serviceYearStudyIndividualCalls;
	
	int _thisMonth;
	int _lastMonth;
	int _thisYear;
	
	int _books[kMonthsShown];
	int _brochures[kMonthsShown];
	int _minutes[kMonthsShown];
	int _quickBuildMinutes[kMonthsShown];
	int _magazines[kMonthsShown];
	int _returnVisits[kMonthsShown];
	int _bibleStudies[kMonthsShown];
	int _campaignTracts[kMonthsShown];

	NSMutableArray *_individualCalls[kMonthsShown];

	int _selectedMonth;
	BOOL _emailActionSheet;
	NSString *_serviceYearText;
	
}

@end
