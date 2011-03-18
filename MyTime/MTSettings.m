#import "MTSettings.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

@implementation MTSettings
MTSettings *cachedSettings;

+ (MTSettings *)settings
{
	if(cachedSettings == nil)
	{
		cachedSettings = [[MTSettings settingsInManagedObjectContext:[[MyTimeAppDelegate sharedInstance] managedObjectContext]] retain];
	}
	return cachedSettings;
}

+ (MTSettings *)settingsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	MTSettings *settings;
	NSArray *array = [managedObjectContext fetchObjectsForEntityName:[MTSettings entityName] withPredicate:nil];

	if(array == nil || [array count] == 0) 
	{
		settings = [NSEntityDescription insertNewObjectForEntityForName:[MTSettings entityName]
												 inManagedObjectContext:managedObjectContext];
		NSError *error = nil;
		if (![managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
	}
	else
	{
		settings = [array objectAtIndex:0];
	}
	
	return settings;
}
@end
