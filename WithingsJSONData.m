//
//  WithingsJSONData.m
//  PulseBeat
//
//  Created by Omar Metwally on 10/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "WithingsJSONData.h"
#import "MetasomeDataPointStore.h"


@implementation WithingsJSONData
@synthesize name, jsonData, numberOfPoints;


-(id)initWithDictionary:(NSDictionary *)dict dataName:(NSString *)dn
{
    self = [super init];
    if (self) {
        
        [self setName:dn];
        jsonData = dict;
        [self setNumberOfPoints:[[[jsonData objectForKey:[self name]] objectForKey:@"measuregrps"] count]];
        
        NSLog(@"numberOfPoints: %i", self.numberOfPoints);
        
    }
    
    return self;
}

-(void)saveToDataPointStore:(NSString *)parameterName
{
    if ( self.numberOfPoints < 1 )
        return;

    NSArray *secondIteration = [[jsonData objectForKey:@"body"] objectForKey:@"measuregrps"];
                                
    // iterate through the array of data in "measuregrps"
    for (int counter = 0; counter < [secondIteration count]; counter++) {
        
        for (int counter2 = 0; counter2 < [[[secondIteration objectAtIndex:counter] valueForKey:@"measures"] count]; counter2++ ) {
            
            NSString *valueString = [[[[secondIteration objectAtIndex:counter] valueForKey:@"measures"] objectAtIndex:counter2] valueForKey:@"value"];
            
            NSString *typeString = [[[[secondIteration objectAtIndex:counter] valueForKey:@"measures"] objectAtIndex:counter2] valueForKey:@"type"];
            
            int value = [valueString intValue];
            
            NSLog(@"valueString: %@", valueString);
        }
        
        /*
        for (int counter2 = 0; counter2 < [secondIteration count] - 1; counter2++) {
            NSString *string = [[secondIteration objectAtIndex:counter2] valueForKey:@"value"];
            NSLog(@"string value: %@", string);
        
        }
        */
        
    }
    /*
    for (NSDictionary *d in [jsonData objectForKey:[self name]] ) {
        NSString *dateString = [d objectForKey:@"dateTime"];
        NSString *valueString = [d objectForKey:@"value"];
        
        // NSLog(@"dateString = %@, valueString = %@", dateString, valueString);
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormat dateFromString:dateString];
        
        float valueToSave = [valueString floatValue];
        
        // in case of sleep, convert minutes asleep to hours
        if ( [parameterName isEqualToString:@"Sleep hours"] ) {
            valueToSave = (valueToSave / 60.0);
        }
        
        [[MetasomeDataPointStore sharedStore] addPointWithName:parameterName value:valueToSave date:date.timeIntervalSince1970 options:noOptions];
        
        BOOL result = [[MetasomeDataPointStore sharedStore] saveChanges];
        
        if (!result) {
            NSLog(@"Error saving Fitbit data to CoreData!");
        }
        
    }
    */
}

@end
