//
//  MetasomeEventStore.m
//  Metasome
//
//  Created by Omar Metwally on 8/26/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeEventStore.h"
#import "MetasomeEvent.h"
#import "Legend.h"

@implementation MetasomeEventStore
float const EVENT_BAR_WIDTH = 30.0;

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
        allEventLabels = [[NSMutableArray alloc] init];
        
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

-(void)generateEventLabels:(Legend *)legend {
    NSMutableArray *events = [[NSMutableArray alloc] initWithArray:allEvents];
    float horizontalPos, verticalPos;
    
    [allEventLabels removeAllObjects];
    
    for (MetasomeEvent *ev in events) {
        if ([[ev date] timeIntervalSince1970] > [legend since] && [ev visible]) {
            
            horizontalPos = ([[ev date] timeIntervalSince1970] - [legend minValueOnHorizontalAxis]) * [legend horizontalScaleFactor] + [legend originHorizontalOffset];
            
            verticalPos = [legend topBuffer];
            
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalPos, verticalPos, EVENT_BAR_WIDTH, [legend verticalAxisLength])];
            
            eventLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
            eventLabel.layer.cornerRadius = 5;
            [eventLabel.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
            
            [eventLabel.layer setBorderWidth:1.0];
            [eventLabel setText:[ev title]];
            [eventLabel setTextAlignment:NSTextAlignmentCenter];
            [eventLabel setTextColor:[UIColor redColor]];
            [eventLabel setAdjustsFontSizeToFitWidth:YES];
            eventLabel.layer.drawsAsynchronously = YES;
            
            [allEventLabels addObject:eventLabel];
            
        }
    }
        
}

-(void)drawEvents:(UIView *)v
{
    
    for (UILabel *l in allEventLabels) {
        //[l removeFromSuperview];
        [v addSubview:l];
    }
    
}

-(void)removeLabelsFromSuperview:(UIView *)v
{
    //[allEventLabels removeAllObjects];
    
    for (UILabel *l in allEventLabels) {
        
    }
}

@end
