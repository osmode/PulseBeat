//
//  GraphView.h
//  Metasome
//
//  Created by Omar Metwally on 8/21/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MetasomeParameter.h"

// Based on MetasomeParameter.h
/*
typedef enum {
    sliderInput,
    integerInput,
    floatInput
} ParameterInputType;
 */

@class LineView;
@interface GraphView : UIScrollView 
{
    ParameterInput inputType;
    UILabel *titleLabel;
    UIWindow *thisWindow;
    NSMutableArray *hoveringLabels;
    
}
@property NSString *name;
@property (nonatomic) int scrollViewWidth;
@property (nonatomic) int scrollViewHeight;

//for scaling along the horizontal axis (i.e. along the screen's y-axis)
@property (nonatomic) float horizontalScaleFactor;
//for scaling along the vertical axis (i.e. along the screen's x-axis)
@property (nonatomic) float verticalScaleFactor;

@property (nonatomic) float minValueOnHorizontalAxis;
@property (nonatomic) float maxValueOnHorizontalAxis;
@property (nonatomic) float minValueOnVerticalAxis;
@property (nonatomic) float maxValueOnVerticalAxis;

@property (nonatomic) float originHorizontalOffset;
@property (nonatomic) float originVerticalOffset;
@property (nonatomic) float topBuffer, bottomBuffer, rightBuffer, leftBuffer;
@property (nonatomic) float horizontalAxisLength, verticalAxisLength;
@property (nonatomic, strong) NSString *graphTitle;

@property (nonatomic) CGContextRef ctx;
@property (nonatomic) CGContextRef parentContext;


@property (nonatomic) CGAffineTransform transform;
@property (nonatomic, copy) void (^clearSubviewBlock)(void);
@property (nonatomic, weak) UIView *underViewPointer;
@property (nonatomic, strong) LineView *hoveringVerticalLine;
@property (nonatomic, copy) NSMutableArray *pointsToGraph;

-(float)maxValue:(NSArray *)array;
-(void)drawText:(NSString *)writeMe fontSize:(float)size horizontalLocation:(float)horizonal verticalLocation:(float)vertical rotation:(float)radians;
-(void)drawLabels;
-(NSMutableArray *)hoveringLabels;

@end

