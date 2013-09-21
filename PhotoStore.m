//
//  PhotoStore.m
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "PhotoStore.h"
#import "Photo.h"

@implementation PhotoStore

+(PhotoStore *)sharedStore
{
    static PhotoStore *sharedStore = nil;
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
        
        // The managed object context can managed undo
        [context setUndoManager:nil];
        [self loadAllPhotos];
        
    }
    return self;
}

-(void)removePhoto:(Photo *)p
{
    [context deleteObject:p];
    [allPhotos removeObjectIdenticalTo:p];
}
-(void)moveItemAtIndex:(int)from toIndex:(int)to
{
    if (from == to) return;
    Photo *p = [allPhotos objectAtIndex:from];
    
    [allPhotos removeObjectAtIndex:from];
    [allPhotos insertObject:p atIndex:to];
    
    // Compte a new orderingValue fro the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (to > 0) {
        lowerBound = [[allPhotos objectAtIndex:to - 1] orderingValue];
    } else {
        lowerBound = [[allPhotos objectAtIndex:1] orderingValue] - 2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if (to < [allPhotos count] - 1) {
        upperBound = [[allPhotos objectAtIndex:to + 1] orderingValue];
    } else {
        upperBound = [[allPhotos objectAtIndex:to -1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    [p setOrderingValue:newOrderValue];
}

-(NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the one and only document directory
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingFormat:@"photos.data"];
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

-(void)loadAllPhotos
{
    if(!allPhotos) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Photo"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if(!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        allPhotos = [[NSMutableArray alloc] initWithArray:result];
    }
}
-(NSMutableArray *)allPhotos
{
    return allPhotos;
}


@end
