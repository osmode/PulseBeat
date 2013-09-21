//
//  PhotoArchiveStore.m
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "PhotoArchiveStore.h"

@implementation PhotoArchiveStore

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}
+(PhotoArchiveStore *)sharedStore
{
    static PhotoArchiveStore *sharedStore = nil;
    if (!sharedStore) {
        // Create a singleton
        sharedStore = [[super allocWithZone:NULL] init];
    }
    return sharedStore;
}

-(id)init
{
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [dictionary setObject:i forKey:s];
}
-(UIImage *)imageForKey:(NSString *)s
{
    return [dictionary objectForKey:s];
}
-(void)deleteImageForKey:(NSString *)s
{
    if (!s)
        return;
    [dictionary removeObjectForKey:s];
}

@end
