//
//  MetasomeParameterStore.m
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeParameterStore.h"
#import "MetasomeParameter.h"

@implementation MetasomeParameterStore
@synthesize  sections, parameterArray, heartList, lungList, diabetesList, customList, currentList;
@synthesize userEmail;

float const MAX_SLIDER_VALUE = 100.0;


+(MetasomeParameterStore *)sharedStore
{
    //a static variable is initialized only once
    static MetasomeParameterStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
        /*
        MetasomeParameter *p = [[MetasomeParameter alloc] initWithParameterName:@"Heart rate"
                                                                      inputType:1];
        [sharedStore addParameter:p];
        [sharedStore addParameter:[[MetasomeParameter alloc] initWithParameterName:@"Systolic blood pressure" inputType:1]];
         */
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
        
        sections = [[NSMutableArray alloc] initWithObjects:@"Heart", @"Lung", @"Diabetes", @"Custom", nil];
            
        parameterArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        int numHeart = [[[parameterArray objectAtIndex:0] valueForKey:@"list"] count];
        int numLung = [[[parameterArray objectAtIndex:1] valueForKey:@"list"] count];
        int numDiabetes = [[[parameterArray objectAtIndex:2] valueForKey:@"list"] count];
        int numCustom = [[[parameterArray objectAtIndex:3] valueForKey:@"list"] count];
        
        // Load user email address if it exists
        // This is not in a dictionary like the parameter lists
        // Check if email has been added before trying to retrieve
        if ([parameterArray count] > 4) {
            userEmail = [parameterArray objectAtIndex:4];
        }
            
        //If loading for the first time, load default list;
        // Otherwise, initialize heartList, lungList, diabetesList, and customList
        // using loaded data
        
        if ((numHeart + numLung + numDiabetes + numCustom) == 0 ) {
            [self loadDefaultParameters];
            [self saveChanges];
        } else {
            heartList = [[NSMutableArray alloc] initWithArray:[[parameterArray objectAtIndex:0] valueForKey:@"list"]];
            
            lungList = [[NSMutableArray alloc] initWithArray:[[parameterArray objectAtIndex:1] valueForKey:@"list"]];
            
            diabetesList = [[NSMutableArray alloc] initWithArray:[[parameterArray objectAtIndex:2] valueForKey:@"list"]];
            
            customList = [[NSMutableArray alloc] initWithArray:[[parameterArray objectAtIndex:3] valueForKey:@"list"]];
            
        }
        
       // [self loadDefaultParameters];
        currentList = [[NSMutableArray alloc] initWithArray:[[parameterArray objectAtIndex:0] valueForKey:@"list"]];
                
    }
    return self;
}


-(void)addParameter:(MetasomeParameter *)p
{
    [[[[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:[p inputCategory] ]objectForKey:@"list"] addObject:p];
}

-(void)moveItemAtIndex:(int)from toIndex:(int)to inSection:(int)sec
{
    if (from == to) {
        return;
    }

    MetasomeParameter *p = [currentList objectAtIndex:from];
    [currentList removeObjectAtIndex:from];
    [currentList insertObject:p atIndex:to];
    
}

-(NSInteger)numberOfSections
{
    return [parameterArray count];
}
-(NSString *)sectionHeader:(int)sec
{
    if (sec >= [sections count])
        return @"Undefined section";
    return [sections objectAtIndex:sec];
}

-(NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the one and only document directory
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"parameters.archive"];
}

-(BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:parameterArray toFile:path];
}

-(void)loadDefaultParameters
{
    //sections = [[NSMutableArray alloc] initWithObjects:@"Vitals", @"Mind", @"Body", nil];
    
    parameterArray = [[NSMutableArray alloc] init];
    
    MetasomeParameter *a = [[MetasomeParameter alloc] initWithParameterName:@"Heart rate" inputType:ParameterInputInteger category:ParameterCategoryHeart maximumValue:200.0];
  
    MetasomeParameter *a2 = [[MetasomeParameter alloc] initWithParameterName:@"Heart rate" inputType:ParameterInputInteger category:ParameterCategoryLung maximumValue:200.0];
    
    MetasomeParameter *b = [[MetasomeParameter alloc] initWithParameterName:@"Blood pressure" inputType:ParameterBloodPressure category:ParameterCategoryHeart maximumValue:220.0] ;
    
    MetasomeParameter *b2 = [[MetasomeParameter alloc] initWithParameterName:@"Blood pressure" inputType:ParameterBloodPressure category:ParameterCategoryLung maximumValue:220.0] ;
    
    MetasomeParameter *b3 = [[MetasomeParameter alloc] initWithParameterName:@"Blood pressure" inputType:ParameterBloodPressure category:ParameterCategoryDiabetes maximumValue:220.0] ;
    
    MetasomeParameter *d = [[MetasomeParameter alloc] initWithParameterName:@"Blood sugar" inputType:ParameterInputInteger category:ParameterCategoryDiabetes maximumValue:600.0] ;
    
    MetasomeParameter *f = [[MetasomeParameter alloc] initWithParameterName:@"Weight" inputType:ParameterInputFloat category:ParameterCategoryHeart maximumValue:800.0] ;
    
    MetasomeParameter *f2 = [[MetasomeParameter alloc] initWithParameterName:@"Weight" inputType:ParameterInputFloat category:ParameterCategoryDiabetes maximumValue:800.0] ;
    
    MetasomeParameter *dd = [[MetasomeParameter alloc] initWithParameterName:@"Energy" inputType:ParameterInputSlider category:ParameterCategoryHeart maximumValue:MAX_SLIDER_VALUE];
    
    MetasomeParameter *aaa = [[MetasomeParameter alloc] initWithParameterName:@"Shortness of breath" inputType:ParameterInputSlider category:ParameterCategoryHeart maximumValue:MAX_SLIDER_VALUE];
    
     MetasomeParameter *aaa2 = [[MetasomeParameter alloc] initWithParameterName:@"Shortness of breath" inputType:ParameterInputSlider category:ParameterCategoryLung maximumValue:MAX_SLIDER_VALUE];
    
    MetasomeParameter *bbb = [[MetasomeParameter alloc] initWithParameterName:@"Leg swelling" inputType:ParameterInputSlider category:ParameterCategoryHeart maximumValue:MAX_SLIDER_VALUE];
    
    MetasomeParameter *ccc = [[MetasomeParameter alloc] initWithParameterName:@"Cough" inputType:ParameterInputSlider category:ParameterCategoryHeart maximumValue:MAX_SLIDER_VALUE];
    
   MetasomeParameter *ccc2 = [[MetasomeParameter alloc] initWithParameterName:@"Cough" inputType:ParameterInputSlider category:ParameterCategoryLung maximumValue:MAX_SLIDER_VALUE];
    
    MetasomeParameter *eee = [[MetasomeParameter alloc] initWithParameterName:@"Rescue inhaler puffs" inputType:ParameterInputInteger category:ParameterCategoryLung maximumValue:20.0];
    
    // Each parameter can only belong to one list!
    
    heartList = [[NSMutableArray alloc] initWithObjects:aaa, bbb, ccc, a, b, f, dd, nil];
    lungList = [[NSMutableArray alloc] initWithObjects:a2, b2, aaa2, ccc2, eee, nil];
    diabetesList = [[NSMutableArray alloc] initWithObjects:d, f2, b3, nil];
    customList = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *heartListArrayDict = [NSMutableDictionary dictionaryWithObject:heartList forKey:@"list"];
    NSMutableDictionary *lungListArrayDict = [NSMutableDictionary dictionaryWithObject:lungList forKey:@"list"];
    NSMutableDictionary *diabetesListArrayDict = [NSMutableDictionary dictionaryWithObject:diabetesList forKey:@"list"];
    NSMutableDictionary *customListArrayDict = [NSMutableDictionary dictionaryWithObject:customList forKey:@"list"];
    
    [parameterArray addObject:heartListArrayDict];
    [parameterArray addObject:lungListArrayDict];
    [parameterArray addObject:diabetesListArrayDict];
    [parameterArray addObject:customListArrayDict];
    
}

@end
