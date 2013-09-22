//
//  MetasomeEventStore.h
//  Metasome
//
//  Created by Omar Metwally on 8/26/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MetasomeEvent, Legend;
@interface MetasomeEventStore : NSObject
{
    NSMutableArray *allEvents;
    NSMutableArray *allEventLabels;
}

+(MetasomeEventStore *)sharedStore;
-(id)init;
-(NSArray *)allEvents;
-(void)addEvent:(MetasomeEvent *)ev;
-(void)removeEvent:(MetasomeEvent *)ev;
-(void)moveItemAtIndex:(int)from toIndex:(int)to;
-(BOOL)saveChanges;
-(NSString *)itemArchivePath;
-(void)drawEvents:(UIView *)v;
-(void)generateEventLabels:(Legend *)legend;
-(void)removeLabelsFromSuperview:(UIView *)v;

@end

