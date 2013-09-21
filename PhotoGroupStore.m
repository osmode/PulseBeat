//
//  PhotoGroupStore.m
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "PhotoGroupStore.h"
#import "PhotoGroup.h"

@implementation PhotoGroupStore
@synthesize photoGroupArray;

+(PhotoGroupStore *)sharedStore
{
    static PhotoGroupStore *sharedStore = nil;
    
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
        photoGroupArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        NSLog(@"unarchived %i photo groups", [photoGroupArray count]);
    }
    
    return self;
}

-(void)moveItemAtIndex:(int)from toIndex:(int)to
{
    if (from == to) return;
    PhotoGroup *g = [photoGroupArray objectAtIndex:from];
    [photoGroupArray removeObjectAtIndex:from];
    [photoGroupArray insertObject:g atIndex:to];
}

-(NSInteger)numberOfSections
{
    return [photoGroupArray count];
}
-(NSString *)sectionHeader:(int)sec
{
    return @"Photo Groups";
}

-(NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingString:@"photoGroups.archive"];
}
-(BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    NSLog(@"%i items in photoGroupArray on saveChanges", [photoGroupArray count]);
    return [NSKeyedArchiver archiveRootObject:photoGroupArray toFile:path];
}

-(void)addPhotoGroup:(PhotoGroup *)photoGroup
{
    [[[PhotoGroupStore sharedStore] photoGroupArray] addObject:photoGroup];
    PhotoGroup *test = [[PhotoGroup alloc] init];
    [photoGroupArray addObject:test];
    
    NSLog(@"photoGroupArray now has %i objects",[photoGroupArray count]);

}


@end
