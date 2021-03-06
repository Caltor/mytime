//
//  MetadataPickerViewController.m
//  MyTime
//
//  Created by Brent Priddy on 2/4/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "MetadataPickerViewController.h"
#import "MetadataViewController.h"
#import "PSLocalization.h"

@implementation MetadataPickerViewController
@synthesize delegate = _delegate;

- (IBAction)done
{
	if(_delegate && [_delegate respondsToSelector:@selector(metadataPickerViewControllerChanged:)])
	{
		[_delegate metadataPickerViewControllerDone:self];
	}
}



- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    VERY_VERBOSE(NSLog(@"pickerView: viewForRow:%d inComponent:%d", row, component);)
	return [_metadataArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	_selection = row;
	if(_delegate && [_delegate respondsToSelector:@selector(metadataPickerViewControllerChanged:)])
	{
		[_delegate metadataPickerViewControllerChanged:self];
	}
}

// DataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    VERY_VERBOSE(NSLog(@"pickerView: numberOfRowsInComponent: %d", component);)
	return _metadataArray.count;
}

- (void) dealloc
{
    VERY_VERBOSE(NSLog(@"PublicationPicker: dealloc");)
	[_metadataArray release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	navigationTitle.title = NSLocalizedString(@"Select What To Sort By", @"In the \"Sorted By...\" view this is the prompt that appears to tell the user to pick what to sort by");
}

// initialize this view given the curent configuration
- (id) initWithMetadata:(NSString *)metadata
{
    if((self = [super initWithNibName:@"MetadataPickerView" bundle:[NSBundle mainBundle]])) 
    {
        // we are managing the picker's data and display
		_metadataArray = [[MetadataViewController metadataNames] copy];

        _selection = 0;
		_selection = [_metadataArray indexOfObject:metadata];
		if(_selection ==  NSNotFound)
		{
			_selection = 0;
		}
		pickerView.dataSource = self;
		pickerView.delegate = self;
		
		[pickerView reloadAllComponents];
		[pickerView selectRow:_selection inComponent:0 animated:NO];
    }
    
    return(self);
}

- (void)reloadData
{
	NSString *selectedName = [[_metadataArray objectAtIndex:_selection] retain];
	[_metadataArray release];
	_metadataArray = [[MetadataViewController metadataNames] copy];
	
	// try to find the selection in the new array
	_selection = [_metadataArray indexOfObject:selectedName];
	[selectedName release];
	if(_selection == NSNotFound)
	{
		_selection = 0;
	}
	[pickerView reloadAllComponents];
	[pickerView selectRow:_selection inComponent:0 animated:NO];
}

- (void)setMetadata:(NSString *)metadata
{
	[_metadataArray release];
	_metadataArray = [[MetadataViewController metadataNames] copy];
	int i = [_metadataArray indexOfObject:metadata];
	if(i !=  NSNotFound)
	{
		_selection = i;
	}
	[pickerView reloadAllComponents];
	[pickerView selectRow:_selection inComponent:0 animated:NO];
}

- (NSString *)metadata
{
	return [[[_metadataArray objectAtIndex:[pickerView selectedRowInComponent:0]] retain] autorelease];
}

@end
