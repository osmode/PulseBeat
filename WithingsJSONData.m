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
        
        NSString *entryDateTimestampString = [[secondIteration objectAtIndex:counter] valueForKey:@"date"];
        
        NSDate *entryDate = [[NSDate alloc] initWithTimeIntervalSince1970:[entryDateTimestampString floatValue]];
        
        for (int counter2 = 0; counter2 < [[[secondIteration objectAtIndex:counter] valueForKey:@"measures"] count]; counter2++ ) {
            
            NSString *valueString = [[[[secondIteration objectAtIndex:counter] valueForKey:@"measures"] objectAtIndex:counter2] valueForKey:@"value"];
            
            NSString *typeString = [[[[secondIteration objectAtIndex:counter] valueForKey:@"measures"] objectAtIndex:counter2] valueForKey:@"type"];
            
            int value = [valueString intValue];
            int type = [typeString intValue];
            
            
            //NSLog(@"valueString: %@, typeString: %@, entryDate: %@", valueString, typeString, entryDate);
            
            switch (type) {
                case 9:  // diastolic blood pressure
                    [[MetasomeDataPointStore sharedStore] addPointWithName:@"Blood pressure" value:value date:entryDate.timeIntervalSince1970 options:diastolicOptions];
                    break;
                    
                case 10:  // systolic blood pressure
                    [[MetasomeDataPointStore sharedStore] addPointWithName:@"Blood pressure" value:value date:entryDate.timeIntervalSince1970 options:systolicOptions];
                    break;
                case 11:  // heart rate
                    [[MetasomeDataPointStore sharedStore] addPointWithName:@"Heart rate" value:value date:entryDate.timeIntervalSince1970 options:noOptions];
                
                    default:
                        break;
            }
            
        }
    }
        
        // save changes to database
        BOOL result = [[MetasomeDataPointStore sharedStore] saveChanges];
        
        if (!result) {
            NSLog(@"Error saving Fitbit data to CoreData!");
        }
    
}

@end
