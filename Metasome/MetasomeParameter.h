//
//  MetasomeParameter.h
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
typedef enum {
    ParameterCategoryVitals,
    ParameterCategoryMind,
    ParameterCategoryBody
} ParameterCategory;
*/
typedef enum {
    ParameterCategoryHeart,
    ParameterCategoryLung,
    ParameterCategoryDiabetes,
    ParameterCategoryCustom
} ParameterCategory;

typedef enum {
    ParameterInputSlider,
    ParameterInputInteger,
    ParameterInputFloat,
    ParameterInputPhoto,
    ParameterBloodPressure  // Contains 2 text input fields
} ParameterInput;

typedef enum {
    FitbitInput,
    WithingsInput
} InputType;

@interface MetasomeParameter : NSObject <NSCoding>
{
    
}

//e.g. "shortness of breath
@property (nonatomic, copy) NSString *parameterName;

// 0 for slider, 1 for integer, 2 for float
@property (nonatomic) int inputType;

// 0 -- vitals; 1 -- mind; 2 -- body
@property (nonatomic) int inputCategory;
@property (nonatomic) BOOL checkedStatus;
@property (nonatomic, strong) NSDate *lastChecked;
@property (nonatomic) int consecutiveEntries;
@property (nonatomic) float maxValue;
@property (nonatomic) BOOL sadOnRightSide;
@property (nonatomic) BOOL isCustomMade;
@property (nonatomic) int apiType;
@property (nonatomic, strong) NSString *units;


-(id)initWithParameterName:(NSString *)name inputType:(int)type category:(int)newCategory maximumValue:(float)value;
-(void)resetCheckmark;
-(BOOL)isWithinMaxValue:(float)value;
-(BOOL)incrementConsecutiveCounter;


@end

