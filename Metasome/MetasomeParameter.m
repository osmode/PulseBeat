//
//  MetasomeParameter.m
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeParameter.h"

@implementation MetasomeParameter
@synthesize parameterName, inputType, inputCategory, checkedStatus, lastChecked, maxValue, sadOnRightSide;
@synthesize isCustomMade, consecutiveEntries, apiType, units;


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
        
        // not a fitbit-derived parameter unless other specified
        [self setApiType:-1];
        lastChecked = [[NSDate alloc] init];
        
        consecutiveEntries = 0;
        
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
    [aCoder encodeBool:sadOnRightSide forKey:@"sadOnRightSide"];
    [aCoder encodeBool:isCustomMade forKey:@"isCustomMade"];
    [aCoder encodeInt:consecutiveEntries forKey:@"consecutiveEntries"];
    [aCoder encodeInt:apiType forKey:@"apiType"];
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
        [self setSadOnRightSide:[aDecoder decodeBoolForKey:@"sadOnRightSide"]];
        [self setIsCustomMade:[aDecoder decodeBoolForKey:@"isCustomMade"]];
        [self setConsecutiveEntries:[aDecoder decodeIntForKey:@"consecutiveEntries"]];
        [self setApiType:[aDecoder decodeIntForKey:@"apiType"]];
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

-(BOOL)incrementConsecutiveCounter
{
    /*
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components
    
    int todayDay = [todayComponents day];
    
    // get last entered date's day
    NSDateComponents *lastEnteredDateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[self lastChecked]];
                                                   
   int lastEnteredDay = [lastEnteredDateComponents day];
    
    // was the last entry today?
    return (todayDay == lastEnteredDay);
    */
    
    NSTimeInterval distanceBetweenDates = [[NSDate date] timeIntervalSinceDate:[self lastChecked]];
    double secondsInAnHour = 3600.0;
    int hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    
    NSLog(@"hoursBetweenDates: %i", hoursBetweenDates);
    
    //if (hoursBetweenDates < 36) {
    if (hoursBetweenDates < 36) {

        consecutiveEntries += 1;
        
        return YES;
    }
    else {
        consecutiveEntries = 0;
        
        return NO;
    }
            
    return YES;
    
}

@end
