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
@dynamic red, green, blue;
@dynamic options;


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


@end
