//
//  MetasomeParameter.m
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeParameter.h"

@implementation MetasomeParameter
@synthesize parameterName, inputType, inputCategory, checkedStatus, lastChecked, maxValue;


-(id)initWithParameterName:(NSString *)name inputType:(int)type category:(int)newCategory maximumValue:(float)value
{
    self = [super init];
    if (self) {
        [self setParameterName:name];
        [self setInputType:type];
        [self setInputCategory:newCategory];
        [self setMaxValue:value];
        
        // Parameters are not checked by default;
        [self setCheckedStatus:NO];
        lastChecked = [[NSDate alloc] init];
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:parameterName forKey:@"parameterName"];
    [aCoder encodeInt:inputType forKey:@"inputType"];
    [aCoder encodeInt:inputCategory forKey:@"inputCategory"];
    [aCoder encodeObject:lastChecked forKey:@"lastChecked"];
    [aCoder encodeBool:checkedStatus forKey:@"checkedStatus"];
    [aCoder encodeFloat:maxValue forKey:@"maxValue"];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setParameterName:[aDecoder decodeObjectForKey:@"parameterName"]];
        [self setInputType:[aDecoder decodeIntForKey:@"inputType"]];
        [self setInputCategory:[aDecoder decodeIntForKey:@"inputCategory"]];
        [self setLastChecked:[aDecoder decodeObjectForKey:@"lastChecked"]];
        [self setCheckedStatus:[aDecoder decodeBoolForKey:@"checkedStatus"]];
        [self setMaxValue:[aDecoder decodeFloatForKey:@"maxValue"]];
    }
         return self;
}

-(NSString *)description
{
    return [self parameterName];
}

-(void)resetCheckmark
{
    // resets checkmarks only at midnight of next day
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit |  NSMinuteCalendarUnit ;

    NSDate *currentDate = [NSDate date];
    NSDate *tomorrowDate = [currentDate dateByAddingTimeInterval:(60*60*24)];
    
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:tomorrowDate];
        
    [dateComponents setHour:0];
    [dateComponents setMinute:1];
    
    NSDate *resetDate = [calendar dateFromComponents:dateComponents];
    
    // if the current date is beyond the reset date, uncheck the parameter
    if ( [[NSDate date] timeIntervalSince1970] > [resetDate timeIntervalSince1970] ) {
        [self setCheckedStatus:NO];
    }
}

-(BOOL)isWithinMaxValue:(float)value
{
    if (value <= [self maxValue])
        return YES;
    
    return NO;
}


@end
