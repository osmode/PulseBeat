//
//  MetasomeDataPoint.m
//  Metasome
//
//  Created by Omar Metwally on 9/8/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeDataPoint.h"


@implementation MetasomeDataPoint

@dynamic parameterName;
@dynamic parameterValue;
@dynamic pDate;
@dynamic hour;
@dynamic orderingValue;
@dynamic parameterType;

-(void)awakeFromFetch
{
    [super awakeFromFetch];
    
}
-(void)awakeFromInsert
{
    [super awakeFromInsert];
    
}

-(id)copyWithZone:(NSZone *)zone
{
    MetasomeDataPoint *dp = [[MetasomeDataPoint alloc] init];
    dp = [self copyWithZone:zone];
    
    return dp;
}

-(float)red
{
    if ([self hour] >=4 && [self hour] <9)
        return  1.0;
    else
        return 0.0;
}

-(float)green
{
    if ([self hour] >=9 && [self hour] < 19)
        return 1.0;
    else
        return 0.0;
}

-(float)blue
{
    if ([self hour] >=19 || [self hour] <4)
        return 1.0;
    else
        return 0.0;
}
@end
