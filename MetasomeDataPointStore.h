//
//  MetasomeDataPointStore.h
//  Metasome
//
//  Created by Omar Metwally on 8/20/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetasomeDataPoint;
@class MetasomeParameter;

@interface MetasomeDataPointStore : NSObject
{
    NSMutableArray *allPoints;
    NSMutableArray *allParameterTypes;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    
}

// Points to the name of the parameter to graph
@property (nonatomic, copy) NSString *toGraph;

// Points to the actual MetasomeParameter to graph
@property (nonatomic, strong) MetasomeParameter *parameterToGraph;

@property (nonatomic, strong) NSDate *since;

+(MetasomeDataPointStore *)sharedStore;
-(NSMutableArray *)allPoints;
-(void)addPointWithName:(NSString *)pName value:(float)pValue date:(float)pDate;
-(void)removePoint:(MetasomeDataPoint *)p;
-(NSString *)itemArchivePath;
-(BOOL)saveChanges;
-(NSArray *)pointsWithParameterName:(NSString *)pn fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
-(void)deleteAllPoints;
-(void)deleteTodayPoints;

@end
