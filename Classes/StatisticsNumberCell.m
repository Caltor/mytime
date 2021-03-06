//
//  StatisticsNumberCell.m
//  MyTime
//
//  Created by Brent Priddy on 4/12/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "StatisticsNumberCell.h"


@implementation StatisticsNumberCell
@synthesize nameLabel;
@synthesize countLabel;
@synthesize realCountLabel;
@synthesize editingCountLabel;
@synthesize subtractButton;
@synthesize addButton;
@synthesize delegate;

- (void)dealloc
{
	self.nameLabel = nil;
	self.realCountLabel = nil;
	self.countLabel = nil;
	self.editingCountLabel = nil;
	self.subtractButton = nil;
	self.addButton = nil;
	
	[super dealloc];
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
	BOOL editing = self.editing;
	
	[UIView beginAnimations:nil context:nil];
	// Editing -> not editing:
	//    hide the buttons and make the count move to the right
	// Not editing -> editing
	//    show the buttons and make the count move to the left
	
	UILabel *referenceLabel = editing ? self.editingCountLabel : self.countLabel;
	self.realCountLabel.frame = referenceLabel.frame;
	self.realCountLabel.textAlignment = referenceLabel.textAlignment;

	self.addButton.enabled = editing;
	self.addButton.alpha = !editing ? 0 : 1.0;
	self.addButton.hidden = NO;

	self.subtractButton.enabled = editing;
	self.subtractButton.alpha = !editing ? 0 : 1.0;
	self.subtractButton.hidden = NO;
	
	if(self.accessoryType != UITableViewCellAccessoryNone)
	{
		self.selectionStyle = editing ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
	}
	[UIView commitAnimations];
}


- (IBAction)addPressed
{
	self.statistic = statistic + 1;
	if(self.delegate && [self.delegate respondsToSelector:@selector(statisticsNumberCellValueChanged:)])
	{
		[self.delegate statisticsNumberCellValueChanged:self];
	}
}

- (IBAction)subtractPressed
{
	if(statistic >= 1)
	{
		self.statistic = statistic - 1;
		if(self.delegate && [self.delegate respondsToSelector:@selector(statisticsNumberCellValueChanged:)])
		{
			[self.delegate statisticsNumberCellValueChanged:self];
		}
	}
}

- (int)statistic
{
	return statistic;
}

- (void)setStatistic:(int)value
{
	statistic = value;
	realCountLabel.text = [NSString stringWithFormat:@"%u", statistic];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	[super setSelected:selected animated:animated];
	
	if(self.selectionStyle != UITableViewCellSelectionStyleNone)
	{
		UIColor *backgroundColor = selected || animated ? [UIColor clearColor] : [UIColor whiteColor];

		nameLabel.backgroundColor = backgroundColor;
		nameLabel.highlighted = selected;
		nameLabel.opaque = !selected;
		
		realCountLabel.backgroundColor = backgroundColor;
		realCountLabel.highlighted = selected;
		realCountLabel.opaque = !selected;
	}
}


@end
