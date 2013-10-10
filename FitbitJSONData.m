//
//  FitbitJSONData.m
//  PulseBeat
//
//  Created by Omar Metwally on 10/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "FitbitJSONData.h"
#import "MetasomeDataPointStore.h"


@implementation FitbitJSONData
@synthesize name, jsonData, numberOfPoints;


-(id)initWithDictionary:(NSDictionary *)dict dataName:(NSString *)dn
{
    self = [super init];
    if (self) {
        
        [self setName:dn];
        jsonData = dict;
        [self setNumberOfPoints:[[jsonData objectForKey:[self name]] count]];
    }
    
    return self;
}

-(void)saveToDataPointStore:(NSString *)parameterName
{
    if ( [[jsonData objectForKey:[self name]] count] < 1 )
        return;
    
    for (NSDictionary *d in [jsonData objectForKey:[self name]] ) {
        NSString *dateString = [d objectForKey:@"dateTime"];
        NSString *valueString = [d objectForKey:@"value"];
        
        NSLog(@"dateString = %@, valueString = %@", dateString, valueString);
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormat dateFromString:dateString];
        
        [[MetasomeDataPointStore sharedStore] addPointWithName:parameterName value:[valueString intValue] date:date.timeIntervalSince1970 options:noOptions];
        
    }

}

@end
