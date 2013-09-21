//
//  MetasomeEventStore.m
//  Metasome
//
//  Created by Omar Metwally on 8/26/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeEventStore.h"
#import "MetasomeEvent.h"

@implementation MetasomeEventStore

+(MetasomeEventStore *)sharedStore
{
    static MetasomeEventStore *sharedStore = nil;
    
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
        NSString *path = [self itemArchivePath];
        allEvents = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        NSLog(@"Number of events retrieved: %i", [allEvents count]);
        
    }
    if (!allEvents) {
        allEvents = [[NSMutableArray alloc] init];
    }
    
    return self;
    
}

-(NSArray *)allEvents
{
    return allEvents;
}
-(void)addEvent:(MetasomeEvent *)ev
{
    [allEvents addObject:ev];
}
-(void)moveItemAtIndex:(int)from toIndex:(int)to
{
    if (from == to) return;
    
    MetasomeEvent *ev = [allEvents objectAtIndex:from];
    [allEvents removeObjectAtIndex:from];
    [allEvents insertObject:ev atIndex:to];
}
-(void)removeEvent:(MetasomeEvent *)ev
{
    [allEvents removeObjectIdenticalTo:ev];
}
-(NSString *)itemArchivePath
{
    NSArray *documentdirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentdirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"events.archive"];
}
-(BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:allEvents toFile:path];
}


@end
