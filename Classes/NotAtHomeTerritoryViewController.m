//
//  NotAtHomeTerritoryDetailViewController.m
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

#import "NotAtHomeTerritoryViewController.h"
#import "UITableViewTextFieldCell.h"
#import "NotesViewController.h"
#import "NotAtHomeStreetViewController.h"
#import "UITableViewTitleAndValueCell.h"
#import "UITableViewMultilineTextCell.h"
#import "MTTerritoryStreet.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PSTextFieldCellController.h"
#import "PSTextViewCellController.h"
#import "PSPersonPickerTextFieldCellController.h"
#import "PSLocalization.h"

@interface NotAtHomeTerritoryViewController ()
- (void)resignAllFirstResponders;
@end


@interface NotAtHomeTerritoryViewCellController : NSObject<TableViewCellController>
{
	NotAtHomeTerritoryViewController *delegate;
}
@property (nonatomic, assign) NotAtHomeTerritoryViewController *delegate;
@end
@implementation NotAtHomeTerritoryViewCellController
@synthesize delegate;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}
@end



/******************************************************************
*
*   NAHTerritoryStreetCellController
*
******************************************************************/
#pragma mark NAHTerritoryStreetCellController

@interface NAHTerritoryStreetCellController : NotAtHomeTerritoryViewCellController <NotAtHomeStreetViewControllerDelegate>
{
@private	
	MTTerritoryStreet *street;
}
@property (nonatomic, retain) MTTerritoryStreet *street;
@end
@implementation NAHTerritoryStreetCellController
@synthesize street;

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"StreetCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.textLabel.text = street.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", street.houses.count];
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.delegate resignAllFirstResponders];
	NotAtHomeStreetViewController *controller = [[NotAtHomeStreetViewController alloc] initWithStreet:street newStreet:NO];
	controller.delegate = self;
	[self.delegate.navigationController pushViewController:controller animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
	[controller release];
}

- (void)notAtHomeStreetViewControllerDone:(NotAtHomeStreetViewController *)notAtHomeStreetViewController
{
	NSError *error = nil;
	if(![self.delegate.territory.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
	}

	[self.delegate.navigationController popViewControllerAnimated:YES];
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %@", indexPath);)
		
		[self.street.managedObjectContext deleteObject:self.street];
		self.street = nil;
		
		NSError *error = nil;
		if(![self.delegate.territory.managedObjectContext save:&error])
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
		}
		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
}

@end

/******************************************************************
 *
 *   NAHTerritoryAddStreetCellController
 *
 ******************************************************************/
#pragma mark NAHTerritoryAddStreetCellController

@interface NAHTerritoryAddStreetCellController : NotAtHomeTerritoryViewCellController <NotAtHomeStreetViewControllerDelegate>
{
@private	
	int section;
	MTTerritoryStreet *temporaryStreet;
}
@property (nonatomic, retain) MTTerritoryStreet *temporaryStreet;
@end
@implementation NAHTerritoryAddStreetCellController
@synthesize temporaryStreet;

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"NewStreetCell";
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	[cell setValue:NSLocalizedString(@"Add Street", @"button to add streets to the list of not at home streets")];
	return cell;
}

- (void)notAtHomeDetailCanceled
{
	[self.temporaryStreet.managedObjectContext deleteObject:self.temporaryStreet];
	self.temporaryStreet = nil;
	NSError *error = nil;
	if(![self.delegate.territory.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
	}
	[self.delegate dismissModalViewControllerAnimated:YES];
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.delegate resignAllFirstResponders];

	self.temporaryStreet = [MTTerritoryStreet insertInManagedObjectContext:self.delegate.territory.managedObjectContext];
	self.temporaryStreet.territory = self.delegate.territory;
	NotAtHomeStreetViewController *controller = [[[NotAtHomeStreetViewController alloc] initWithStreet:self.temporaryStreet newStreet:YES] autorelease];
	controller.delegate = self;

	section = indexPath.section;

	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"Add Street", @"Title for the a new street in the Territories view");
	[self.delegate presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(notAtHomeDetailCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
}

- (void)notAtHomeStreetViewControllerDone:(NotAtHomeStreetViewController *)notAtHomeStreetViewController
{
	self.temporaryStreet = nil;
	NSError *error = nil;
	if(![self.delegate.territory.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
	}
	
	[self.delegate dismissModalViewControllerAnimated:YES];
	[self.delegate updateAndReload];
}

@end


@implementation NotAtHomeTerritoryViewController
@synthesize territory;
@synthesize delegate;
@synthesize tag;
@synthesize allTextFields;
@synthesize obtainFocus;

- (NSString *)ownerEmailAddress
{
	NSString *name = [[self.territory.ownerEmailAddress retain] autorelease];
	NSNumber *ownerId = self.territory.ownerId;
	if(ownerId)
	{
		NSNumber *ownerEmailId = self.territory.ownerEmailId;
		if(addressBook == nil)
			addressBook = ABAddressBookCreate();
		
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [ownerId intValue]);
		ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
		int index = ABMultiValueGetIndexForIdentifier(emails, [ownerEmailId intValue]);
		if(index > 0 && index < ABMultiValueGetCount(emails))
		{
			name = [(NSString *)ABMultiValueCopyValueAtIndex(emails , index) autorelease];
		}
		CFRelease(emails);
	}	
	return name;
}

- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)
	if(delegate)
	{
		[delegate notAtHomeTerritoryViewControllerDone:self];
	}
}

/******************************************************************
 *
 *   ACTION SHEET DELEGATE FUNCTIONS
 *
 ******************************************************************/
#pragma mark ActionSheet Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	if(deleteAfterEmailing && result != MFMailComposeResultCancelled)
	{
		// delete territory
		[self.territory.managedObjectContext deleteObject:self.territory];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

NSString *emailFormattedStringForCoreDataNotAtHomeTerritory(MTTerritory *territory);

- (BOOL)sendEmail
{
	if([MFMailComposeViewController canSendMail] == NO)
	{
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		alertSheet.title = NSLocalizedString(@"You must setup email on this device to be able to send an email.  Open the Mail application and setup your email account", @"This is a message displayed when the user does not have email setup on their iDevice");
		[alertSheet show];
		return NO;
	}

	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Not At Home Territory, open this on your iPhone/iTouch", @"Subject text for the email that is sent for sending the details of a call to another witness")];
	
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	[string appendString:NSLocalizedString(@"This not at home territory has been turned over to you, here are the details.  If you are a MyTime user, please view this email on your iPhone/iTouch and scroll all the way down to the end of the email and click on the link to import this not at home territory into MyTime.<br><br>", @"This is the first part of the body of the email message that is sent to a user when you click on a Not At Home Territory and then click on the action button in the upper left corner and select transfer or email details")];
	[string appendString:emailFormattedStringForCoreDataNotAtHomeTerritory(self.territory)];
	[string appendString:NSLocalizedString(@"You are able to import this not at home territory into MyTime if you click on the link below while viewing this email from your iPhone/iTouch.  Please make sure that at the end of this email there is a \"VERIFICATION CHECK:\" right after the link, it verifies that all data is contained within this email<br>", @"This is the second part of the body of the email message that is sent to a user when you click on a Not At Home Territory and then click on the action button in the upper left corner and select transfer or email details")];
	
	// now add the url that will allow importing
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self.territory.managedObjectContext dictionaryFromManagedObject:self.territory 
																										  skipRelationshipNames:[NSArray arrayWithObjects:@"self.user", nil]]];
	[string appendString:@"<a href=\"mytime://mytime/addCoreDataNotAtHomeTerritory?"];
	int length = data.length;
	unsigned char *bytes = (unsigned char *)data.bytes;
	for(int i = 0; i < length; ++i)
	{
		[string appendFormat:@"%02X", *bytes++];
	}
	[string appendString:@"\">"];
	[string appendString:NSLocalizedString(@"Click on this link from your iPhone/iTouch", @"This is the text that appears in the link of the email when you are transferring a not at home territory to another witness.  this is the link that they press to open MyTime")];
	[string appendString:@"</a><br><br>"];
	[string appendString:NSLocalizedString(@"VERIFICATION CHECK: all data was contained in this email", @"This is a very important message that is at the end of the email used to transfer a not at home territory to another witness or if you are just emailing a backup to yourself, it verifies that all of the data is contained in the email, if it is not there then all of the data is not in the email and something bad happened :(")];
	
	[string appendString:@"</body></html>"];
	[mailView setMessageBody:string isHTML:YES];
	[string release];
	mailView.mailComposeDelegate = self;

	NSString *emailAddress = [self ownerEmailAddress];
	if(emailAddress && emailAddress.length)
	{
		[mailView setToRecipients:[emailAddress componentsSeparatedByString:@" "]];
	}
	
	[self.navigationController presentModalViewController:mailView animated:YES];
	
	return [MFMailComposeViewController canSendMail];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	//	[sheet dismissAnimated:YES];
	deleteAfterEmailing = NO;
	switch(button)
	{
			//transfer
		case 0:
		{
			deleteAfterEmailing = YES;
			[self sendEmail];
			break;
		}
			// email
		case 1:
		{
			[self sendEmail];
			break;
		}
	}
}


- (void)navigationControlAction:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You can transfer this not at home territory to someone else. Transferring will delete this territory from your data or just emailing the details will keep the data. The witness who gets this email will be able to click on a link in the email and add the territory to MyTime.", @"This message is displayed when the user clicks on a territory and clicks on the \"Action\" button at the top left of the screen")
															 delegate:self
												    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
											   destructiveButtonTitle:NSLocalizedString(@"Transfer, and Delete", @"Transferr this not at home territory to another MyTime user and delete it off of this iphone, but keep the data")
												    otherButtonTitles:NSLocalizedString(@"Email Details", @"Email the not at home territory details to another MyTime user"), nil] autorelease];
	
	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[alertSheet showInView:self.view];
}

- (id)initWithTerritory:(MTTerritory *)theTerritory
{
	return [self initWithTerritory:theTerritory newTerritory:NO];
}

- (id)initWithTerritory:(MTTerritory *)theTerritory newTerritory:(BOOL)newTerritory
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.obtainFocus = newTerritory;
		self.allTextFields = [NSMutableSet set];
		
		self.territory = theTerritory;

		if(!newTerritory)
		{
			self.title = self.territory.name;
			UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
																					 target:self 
																					 action:@selector(navigationControlAction:)] autorelease];
			[self.navigationItem setLeftBarButtonItem:button animated:YES];
		}
		self.hidesBottomBarWhenPushed = YES;
		self.editing = YES;
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	if(addressBook)
	{
		CFRelease(addressBook);
		addressBook = nil;
	}
}

- (void)loadView
{
	[super loadView];
	
	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];	
}


- (void)dealloc
{
	if(addressBook)
	{
		CFRelease(addressBook);
	}
	self.allTextFields = nil;
	self.territory = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)resignAllFirstResponders
{
	for(UITextField *textField in self.allTextFields)
	{
		[textField resignFirstResponder];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self resignAllFirstResponders];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];

		{
			// Territory Name
			PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
			cellController.model = self.territory;
			cellController.modelPath = @"name";
			cellController.placeholder = NSLocalizedString(@"Territory Name/Number", @"This is the territory idetifier that is on the Territories->New/edit territory");
			cellController.selectNextRowResponderIncrement = 1;
			cellController.returnKeyType = UIReturnKeyNext;
			cellController.clearButtonMode = UITextFieldViewModeAlways;
			cellController.autocapitalizationType = UITextAutocapitalizationTypeWords;
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.obtainFocus = self.obtainFocus;
			cellController.allTextFields = self.allTextFields;
			cellController.indentWhileEditing = NO;
			self.obtainFocus = NO;
			
			[self addCellController:cellController toSection:sectionController];
		}
		
		{
			// Territory City
			PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
			cellController.model = self.territory;
			cellController.modelPath = @"city";
			cellController.placeholder = NSLocalizedString(@"City", @"City");
			cellController.selectNextRowResponderIncrement = 1;
			cellController.returnKeyType = UIReturnKeyNext;
			cellController.clearButtonMode = UITextFieldViewModeAlways;
			cellController.autocapitalizationType = UITextAutocapitalizationTypeWords;
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.allTextFields = self.allTextFields;
			cellController.indentWhileEditing = NO;

			[self addCellController:cellController toSection:sectionController];
		}
		
		{
			// Territory State
			PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
			cellController.model = self.territory;
			cellController.modelPath = @"state";
			cellController.placeholder = NSLocalizedString(@"State or Country", @"State or Country");
			cellController.returnKeyType = UIReturnKeyDone;
			cellController.clearButtonMode = UITextFieldViewModeAlways;
			cellController.autocapitalizationType = UITextAutocapitalizationTypeWords;
			cellController.selectNextRowResponderIncrement = 1;
			cellController.allTextFields = self.allTextFields;

			// if the localization does not capitalize the state, then just leave it default to capitalize the first letter
			if([NSLocalizedStringWithDefaultValue(@"State in all caps", @"", [NSBundle mainBundle], @"1", @"Set this to 1 if your country abbreviates the state in all capital letters, otherwise set this to 0") isEqualToString:@"1"])
			{
				cellController.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
				cellController.autocorrectionType = UITextAutocorrectionTypeNo;
			}
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.indentWhileEditing = NO;
			
			[self addCellController:cellController toSection:sectionController];
		}

		{
			// Territory Notes
			PSTextViewCellController *cellController = [[[PSTextViewCellController alloc] init] autorelease];
			cellController.model = self.territory;
			cellController.modelPath = @"notes";
			cellController.placeholder = NSLocalizedString(@"Add Notes", @"Placeholder for adding notes in the Not At Home views");
			cellController.title = NSLocalizedString(@"Notes", @"Not At Homes notes view title");
			cellController.indentWhileEditing = NO;
			
			[self addCellController:cellController toSection:sectionController];
		}
		
		{
			// Territory Owner
			PSPersonPickerTextFieldCellController *cellController = [[[PSPersonPickerTextFieldCellController alloc] init] autorelease];
			cellController.textModel = self.territory;
			cellController.textPath = @"ownerEmailAddress";
			cellController.idPath = @"ownerId";
			cellController.emailIdPath = @"ownerEmailId";
			cellController.placeholder = NSLocalizedString(@"Territory Owner's Email Address", @"this is the label in the Territories View when you press on the Add button and enter in the territory's information");
			cellController.personPickerTitle = NSLocalizedString(@"Email Address", @"pick an email address");
			cellController.indentWhileEditing = NO;
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.allTextFields = self.allTextFields;
			[self addCellController:cellController toSection:sectionController];
		}
	}
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.editingTitle = NSLocalizedString(@"Streets", @"Title of the section in the Not-At-Homes territory view that allows you to add/edit streets in the territory");
		[sectionController release];

		{
			// Add Territory Street
			NAHTerritoryAddStreetCellController *cellController = [[NAHTerritoryAddStreetCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		NSArray *streets = [self.territory.managedObjectContext fetchObjectsForEntityName:[MTTerritoryStreet entityName]
																		propertiesToFetch:nil 
																	  withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																						   [NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:YES], nil]
																			withPredicate:@"territory == %@", self.territory];
		for(MTTerritoryStreet *street in streets)
		{
			// Add Territory Street
			NAHTerritoryStreetCellController *cellController = [[NAHTerritoryStreetCellController alloc] init];
			cellController.delegate = self;
			cellController.street = street;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}
}


@end
