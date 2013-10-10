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
        
        sections = [[NSMutableArray alloc] initWithObjects:@"Heart", @"Lung", @"Metabolic", @"Mind", nil];
            
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
    
    NSLog(@"number of parameters in category: %i", [[[[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:p.inputCategory] objectForKey:@"list"] count]);
    
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

-(void)resetAllCheckmarks
{
    int numCategories = [[[MetasomeParameterStore sharedStore] parameterArray] count];
    int counter = 0;
    while (counter < numCategories - 1) {
        for (MetasomeParameter *p in [[[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:counter] objectForKey:@"list"] )
        {
            [p setCheckedStatus:NO];
        }
        counter += 1;
    }
    
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
    
    parameterArray = [[NSMutableArray alloc] init];
    
    // heart-related parameters
    
    MetasomeParameter *heartRate = [[MetasomeParameter alloc] initWithParameterName:@"Heart rate" inputType:ParameterInputInteger category:ParameterCategoryHeart maximumValue:200.0];
    MetasomeParameter *bloodPressure = [[MetasomeParameter alloc] initWithParameterName:@"Blood pressure" inputType:ParameterBloodPressure category:ParameterCategoryHeart maximumValue:220.0];
    MetasomeParameter *legSwelling = [[MetasomeParameter alloc] initWithParameterName:@"Leg swelling" inputType:ParameterInputSlider category:ParameterCategoryHeart maximumValue:MAX_SLIDER_VALUE];
    [legSwelling setSadOnRightSide:YES];
  
    // lung-related parameters
    MetasomeParameter *shortnessOfBreath = [[MetasomeParameter alloc] initWithParameterName:@"Shortness of breath" inputType:ParameterInputSlider category:ParameterCategoryLung maximumValue:MAX_SLIDER_VALUE];
    [shortnessOfBreath setSadOnRightSide:YES];
    
    MetasomeParameter *cough = [[MetasomeParameter alloc] initWithParameterName:@"Cough" inputType:ParameterInputSlider category:ParameterCategoryLung maximumValue:MAX_SLIDER_VALUE];
    [cough setSadOnRightSide:YES];
    MetasomeParameter *rescueInhalerPuffs = [[MetasomeParameter alloc] initWithParameterName:@"Rescue inhaler puffs" inputType:ParameterInputInteger category:ParameterCategoryHeart maximumValue:10.0];
    
    // metabolic-related parameters
    MetasomeParameter *bloodSugar = [[MetasomeParameter alloc] initWithParameterName:@"Blood sugar" inputType:ParameterInputInteger category:ParameterCategoryDiabetes maximumValue:1000.0] ;
    MetasomeParameter *weight = [[MetasomeParameter alloc] initWithParameterName:@"Weight" inputType:ParameterInputFloat category:ParameterCategoryDiabetes maximumValue:1000.0] ;
    MetasomeParameter *steps = [[MetasomeParameter alloc] initWithParameterName:@"Steps" inputType:ParameterInputInteger category:ParameterCategoryDiabetes maximumValue:500000];
    [steps setIsFitbit:YES];
    
    // mind-related parameters
    MetasomeParameter *mood = [[MetasomeParameter alloc] initWithParameterName:@"Mood" inputType:ParameterInputSlider category:ParameterCategoryCustom maximumValue:MAX_SLIDER_VALUE];
    [mood setSadOnRightSide:NO];
    MetasomeParameter *energy = [[MetasomeParameter alloc] initWithParameterName:@"Energy" inputType:ParameterInputSlider category:ParameterCategoryCustom maximumValue:MAX_SLIDER_VALUE];
    [energy setSadOnRightSide:NO];
    MetasomeParameter *sleepHours = [[MetasomeParameter alloc] initWithParameterName:@"Sleep hours" inputType:ParameterInputFloat category:ParameterCategoryCustom maximumValue:20.0];
    
    // Each parameter can only belong to one list!
    
    heartList = [[NSMutableArray alloc] initWithObjects:heartRate, bloodPressure, legSwelling, nil];
    lungList = [[NSMutableArray alloc] initWithObjects:shortnessOfBreath, cough, rescueInhalerPuffs, nil];
    diabetesList = [[NSMutableArray alloc] initWithObjects:bloodSugar, weight, steps, nil];
    customList = [[NSMutableArray alloc] initWithObjects:mood, energy, sleepHours, nil];
    
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
