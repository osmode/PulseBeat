//
//  MetasomeDataPointStore.m
//  Metasome
//
//  Created by Omar Metwally on 8/20/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeDataPointStore.h"
#import "MetasomeDatapoint.h"

@implementation MetasomeDataPointStore
@synthesize toGraph, since;

+(MetasomeDataPointStore *)sharedStore
{
    static MetasomeDataPointStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}
-(id)init
{
    self = [super init];
    if (self) {

        // Read in Metasome.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // Where does the SQLite file go?
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            [NSException raise:@"Open failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // The managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];
        
        since = nil;
        [self loadAllPoints];

    }

    return self;
}

-(MetasomeDataPoint *)addPointWithName:(NSString *)pName value:(float)pValue date:(float)pDate options:(int)optionsValue
{
    // derive the hour of the day to insert into "hour" column
    NSDate *tempDate = [NSDate dateWithTimeIntervalSince1970:pDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:tempDate];
    
    int newHour = [components hour];
    float red = 0.0;
    float green = 0.0;
    float blue = 0.0;
    
    // set the order
    double order;
    if ([allPoints count] == 0) {
        order = 1.0;
    } else {
        order = [[allPoints lastObject] orderingValue] + 1.0;
        
    }
    
    // create point object and add to 'allPoints' array
    MetasomeDataPoint *newPoint = [NSEntityDescription insertNewObjectForEntityForName:@"DataPoints" inManagedObjectContext:context];
    
    [newPoint setParameterName:pName];
    [newPoint setParameterValue:pValue];
    [newPoint setPDate:pDate];
    [newPoint setOrderingValue:order];
    [newPoint setHour:newHour];
    [newPoint setOptions:optionsValue];
    
    // set the points' RGB values
    if ( newHour>= 4 && newHour < 9 )
        red = 1.0;
    else if ( newHour >=9 && newHour < 19 )
        green = 1.0;
    else
        blue = 1.0;
    
    [newPoint setRed:red];
    [newPoint setGreen:green];
    [newPoint setBlue:blue];
    [allPoints addObject:newPoint];
    
    // method returns a pointer to a MetasomeDataPoint object
    NSLog(@"returning pointer to newPoint");
    return newPoint;

}

-(void)removePoint:(MetasomeDataPoint *)p
{
    [context deleteObject:p];
    [allPoints removeObjectIdenticalTo:p];
}

-(void)moveItemAtIndex:(int)from toIndex:(int)to
{
    if (from == to) return;
    MetasomeDataPoint *p = [allPoints objectAtIndex:from];
    
    [allPoints removeObjectAtIndex:from];
    [allPoints insertObject:p atIndex:to];
    
    // Compte a new orderingValue fro the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (to > 0) {
        lowerBound = [[allPoints objectAtIndex:to - 1] orderingValue];
    } else {
        lowerBound = [[allPoints objectAtIndex:1] orderingValue] - 2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if (to < [allPoints count] - 1) {
        upperBound = [[allPoints objectAtIndex:to + 1] orderingValue];
    } else {
        upperBound = [[allPoints objectAtIndex:to -1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    [p setOrderingValue:newOrderValue];
}

-(NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the one and only document directory
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"datapoints.data"];
}

-(BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    
    return successful;
}

-(NSArray *)pointsWithParameterName:(NSString *)pn fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:@"DataPoints"];
    [request setEntity:e];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"pDate" ascending:YES];
        
    NSPredicate *p = [NSPredicate predicateWithFormat:@"(parameterName like %@) AND (pDate > %f)", pn, fromDate.timeIntervalSince1970];
    [request setPredicate:p];

    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (!result) {
        [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
    }
    
    return result;
    
}


-(void)loadAllPoints
{
    if (!allPoints) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"DataPoints"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"pDate" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        [request setIncludesPropertyValues:NO]; // only create pointers but does not fetch objects values
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        allPoints = [[NSMutableArray alloc] initWithArray:result];
    }
}
-(NSMutableArray *)allPoints
{
    return allPoints;
}
-(void)deleteAllPoints
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:@"DataPoints"];
    [request setEntity:e];
    [request setIncludesPropertyValues:NO]; // only creates pointers but does not fetch object values
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    for (NSManagedObject *obj in result) {
        [context deleteObject:obj];
    }
    
    [self saveChanges];
}
-(void)deleteTodayPoints
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:@"DataPoints"];
    [request setEntity:e];
    
    // yesterday's time stamp
    float pYesterdayDate = [[NSDate date] timeIntervalSince1970]- 86400;
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"pDate > %f", pYesterdayDate];
    [request setPredicate:p];
    
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"pDate" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
    }
    
    NSLog(@"number of records in past day: %i", [result count]);

    for (NSManagedObject *obj in result) {
        [context deleteObject:obj];
    }
    
    [self saveChanges];

}

-(NSManagedObjectContext *)context
{
    return context;
}


@end
