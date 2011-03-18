//
//  AdditionalInformationSortDescriptor.m
//  MyTime
//
//  Created by Brent Priddy on 3/16/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "AdditionalInformationSortDescriptor.h"
#import "MTCall.h"
#import "MTAdditionalInformation.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation AdditionalInformationSortDescriptor
@synthesize path;

-(id)initWithName:(NSString *)theName path:(NSString *)thePath ascending:(BOOL)ascending selector:(SEL)selector
{
    if (self = [super initWithKey:theName ascending:ascending selector:selector])
    {
		self.path = thePath;
    }
    return self;
}

- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2
{
	MTCall *call1 = (MTCall *)object1;
	MTCall *call2 = (MTCall *)object2;
	id item1 = nil;
	id item2 = nil;
	NSArray *additionalInformations;
	NSString *key = self.key;
#if 1
	additionalInformations = [call1.additionalInformation filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type.name == %@", key]];
#else
	NSString *path = self.path;
	
	additionalInformations = [call1.managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformation entityName]
																 propertiesToFetch:[NSArray arrayWithObject:path] 
																	 withPredicate:@"call == %@ && type.name == %@", call1, key];
#endif
	for(MTAdditionalInformation *entry in additionalInformations)
	{
		// only interested in the first one
		item1 = [entry valueForKey:self.path];
		break;
	}

#if 1
	additionalInformations = [call2.additionalInformation filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type.name == %@", key]];
#else
	additionalInformations = [call2.managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformation entityName]
																 propertiesToFetch:[NSArray arrayWithObject:path] 
																	 withPredicate:@"call == %@ && type.name == %@", call2, key];
#endif
	for(MTAdditionalInformation *entry in additionalInformations)
	{
		// only interested in the first one
		item2 = [entry valueForKey:self.path];
		break;
	}
	
	id value;
	if(self.ascending)
		value = [item1 performSelector:self.selector withObject:item2];
	else
		value = [item2 performSelector:self.selector withObject:item1];
	
	return (NSComparisonResult)value;
}

- (id)reversedSortDescriptor
{
    return [[[[self class] alloc] initWithName:[self key] path:self.path ascending:![self ascending] selector:[self selector]] autorelease];
}
@end
