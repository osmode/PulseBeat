//
//  MetasomeDataPoint.h
//  Metasome
//
//  Created by Omar Metwally on 9/8/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MetasomeDataPoint : NSManagedObject <NSCopying>

@property (nonatomic, strong) NSString * parameterName;
@property (nonatomic) float parameterValue;
@property (nonatomic) float pDate;
@property (nonatomic) int32_t hour;
@property (nonatomic) double orderingValue;
@property (nonatomic, strong) NSManagedObject *parameterType;
@property (nonatomic) float red, green, blue;
@property (nonatomic) int32_t options;
@property (nonatomic, strong) NSString *api;

-(float)red;
-(float)green;
-(float)blue;


@end
