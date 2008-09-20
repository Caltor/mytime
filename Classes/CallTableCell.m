//
//  CallTableCell.m
//  MyTime
//
//  Created by Brent Priddy on 7/6/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "CallTableCell.h"
#import "Settings.h"


@implementation CallTableCell

@synthesize call;
@synthesize streetLabel;
@synthesize nameLabel;
@synthesize infoLabel;

#define LEFT_OFFSET 10
	
#define STREET_TOP_OFFSET 2
#define STREET_HEIGHT 22
#define NAME_TOP_OFFSET (STREET_TOP_OFFSET + STREET_HEIGHT + 2)
#define NAME_HEIGHT 14
#define INFO_TOP_OFFSET (NAME_TOP_OFFSET + NAME_HEIGHT + 1)
#define INFO_HEIGHT 28

#define TOTAL_HEIGHT (INFO_TOP_OFFSET + INFO_HEIGHT + STREET_TOP_OFFSET)

+ (float)height
{
	return(TOTAL_HEIGHT);
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
		self.streetLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		streetLabel.backgroundColor = [UIColor clearColor];
		streetLabel.font = [UIFont boldSystemFontOfSize:18];
		streetLabel.textColor = [UIColor blackColor];
		streetLabel.highlightedTextColor = [UIColor whiteColor];
		[self.contentView addSubview: streetLabel];

		self.nameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:12];
		nameLabel.textColor = [UIColor darkGrayColor];
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		[self.contentView addSubview: nameLabel];

		self.infoLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		infoLabel.backgroundColor = [UIColor clearColor];
		infoLabel.font = [UIFont boldSystemFontOfSize:10];
		infoLabel.textColor = [UIColor lightGrayColor];
		infoLabel.highlightedTextColor = [UIColor whiteColor];
		infoLabel.lineBreakMode = UILineBreakModeWordWrap;
		infoLabel.numberOfLines = 0;
		[self.contentView addSubview:infoLabel];
	}
	return self;
}

- (void)dealloc
{
	DEBUG(NSLog(@"%s: dealloc", __FILE__);)
	self.streetLabel = nil;
	self.nameLabel = nil;
	self.infoLabel = nil;
	[super dealloc];
}


- (void)setCall:(NSMutableDictionary *)theCall
{
	call = theCall;
	
	NSString *title = [[[NSString alloc] init] autorelease];
	NSString *houseNumber = [call objectForKey:CallStreetNumber ];
	NSString *street = [call objectForKey:CallStreet];

	if(houseNumber && [houseNumber length] && street && [street length])
		title = [title stringByAppendingFormat:NSLocalizedString(@"%@ %@", @"House number and Street represented by %1$@ as the house number and %2$@ as the street name"), houseNumber, street];
	else if(houseNumber && [houseNumber length])
		title = [title stringByAppendingString:houseNumber];
	else if(street && [street length])
		title = [title stringByAppendingString:street];
	if([title length] == 0)
		title = NSLocalizedString(@"(unknown street)", @"(unknown street) Placeholder Section title in the Sorted By Calls view");

	NSString *info = @"";
	if([[call objectForKey:CallReturnVisits] count] > 0)
	{
		NSMutableDictionary *returnVisit = [[call objectForKey:CallReturnVisits] objectAtIndex:0];
		info = [returnVisit objectForKey:CallReturnVisitNotes];
	}

	streetLabel.text = title;
	nameLabel.text = [call objectForKey:CallName];
	infoLabel.text = info;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so in newLabelForMainText: the labels are made opaque and given a white background.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  
    */
	[super setSelected:selected animated:animated];

	[streetLabel setHighlighted:selected];
	[nameLabel setHighlighted:selected];
	[infoLabel setHighlighted:selected];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	float boundsX = contentRect.origin.x;
	float width = contentRect.size.width;
	CGRect frame;

	frame = CGRectMake(boundsX + LEFT_OFFSET, STREET_TOP_OFFSET, width, STREET_HEIGHT);
	[streetLabel setFrame:frame];

	frame = CGRectMake(boundsX + LEFT_OFFSET, NAME_TOP_OFFSET, width, NAME_HEIGHT);
	[nameLabel setFrame:frame];

	frame = CGRectMake(boundsX + LEFT_OFFSET, INFO_TOP_OFFSET, width, INFO_HEIGHT);
	[infoLabel setFrame:frame];
}


- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}



@end
