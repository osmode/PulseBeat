//
//  MetasomeEventStore.h
//  Metasome
//
//  Created by Omar Metwally on 8/26/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MetasomeEvent;
@interface MetasomeEventStore : NSObject
{
    NSMutableArray *allEvents;
}
+(MetasomeEventStore *)sharedStore;
-(id)init;
-(NSArray *)allEvents;
-(void)addEvent:(MetasomeEvent *)ev;
-(void)removeEvent:(MetasomeEvent *)ev;
-(void)moveItemAtIndex:(int)from toIndex:(int)to;
-(BOOL)saveChanges;
-(NSString *)itemArchivePath;
-(void)drawEvents:(CGContextRef)ctx;


@end

