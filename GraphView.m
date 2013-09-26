//
//  GraphView.m
//  Metasome
//
//  Created by Omar Metwally on 8/21/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "GraphView.h"
#import "MetasomeDataPointStore.h"
#import "MetasomeDataPoint.h"
#import "MetasomeParameter.h"
#import "MetasomeEvent.h"
#import "MetasomeEventStore.h"
#import "Legend.h"
#import "GraphViewController.h"
#import "HoveringLabel.h"
#import "LineView.h"
#import <QuartzCore/QuartzCore.h>


@implementation GraphView

float const POINT_WIDTH = 10;
float const POINT_HEIGHT = 10;
float const HORIZONTAL_NUMBER_OF_INTERVALS = 20.0;
float const AXIS_LABEL_FONTSIZE = 12.0;
//float const EVENT_BAR_WIDTH = 30.0;
float const EVENT_FONT_SIZE = 15.0;
float const ORIGIN_HORIZONTAL_OFFSET = 50.0;
float const ORIGIN_VERTICAL_OFFSET = 50.0;
float const VERTICAL_AXIS_LINE_WIDTH = 3.0;
float const TOP_BUFFER = 50;
float const RIGHT_BUFFER = 180;
float const VERTICAL_NUMBER_OF_INTERVALS = 10.0;
float const MINIMUM_TOUCH_DISTANCE = 100.0;


float const HORIZONTAL_AXIS_LABEL_WIDTH = 30.0;
float const HORIZONTAL_AXIS_LABEL_HEIGHT = 30.0;

@synthesize name, scrollViewWidth, scrollViewHeight;
@synthesize horizontalScaleFactor, verticalScaleFactor;
@synthesize minValueOnHorizontalAxis, maxValueOnHorizontalAxis, minValueOnVerticalAxis, maxValueOnVerticalAxis;
@synthesize originHorizontalOffset, originVerticalOffset, topBuffer, bottomBuffer, rightBuffer, leftBuffer;
@synthesize horizontalAxisLength, verticalAxisLength, graphTitle;
@synthesize ctx, transform;
@synthesize clearSubviewBlock, parentContext;
@synthesize pointsToGraph;
@synthesize parentGraphViewController;
@synthesize legend, drawEventsFlag, dataPointCoordinates;

- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        
        [self setGraphTitle:[[[MetasomeDataPointStore sharedStore] toGraph] stringByAppendingString:@" vs time"]];
        [self setOriginHorizontalOffset:ORIGIN_HORIZONTAL_OFFSET];
        [self setOriginVerticalOffset:ORIGIN_VERTICAL_OFFSET];
        [self setTopBuffer:TOP_BUFFER];
        [self setRightBuffer:RIGHT_BUFFER];
        inputType = [[[MetasomeDataPointStore sharedStore] parameterToGraph] inputType];

        [self initializeGraphView];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:longPressRecognizer];
        
       }
    return self;
}

-(void)longPress:(UIGestureRecognizer *)gr
{
    if ( [gr state] == UIGestureRecognizerStateBegan ) {
        CGPoint touchedPoint = [gr locationInView:self];
        
        [self performSelectorInBackground:@selector(showMenuAtPoint:) withObject:[NSValue valueWithCGPoint:touchedPoint]];
    }
}

-(void)showMenuAtPoint:(NSValue *)point
{
    NSLog(@"number of coordinates: %i", [dataPointCoordinates count]);
    
    CGPoint touched = [point CGPointValue];
    
    CGPoint currentPoint;
    
    // iterate through dataPointCoordinates until a nearby
    // coordinate is found
    
    float smallestX, smallestY;
    float smallestDistance = 1000.0;
    
    for (NSValue *val in dataPointCoordinates) {
        
        currentPoint = [val CGPointValue];
        
        if ( [self distanceBetweenPoint:currentPoint andPoint:touched] < smallestDistance) {
            
            smallestDistance = [self distanceBetweenPoint:currentPoint andPoint:touched];
        
            smallestX = currentPoint.x;
            smallestY = currentPoint.y;
        
        }
        
    }
    
    // check for minimum distance before showing menu
    if (smallestDistance > MINIMUM_TOUCH_DISTANCE)
        return;
    
    // convert screen coordinates of closest point to
    // a value/date pair
    float yValue = (smallestY + [self originVerticalOffset] - [self scrollViewHeight])/(-1*[self verticalScaleFactor]) + [self minValueOnVerticalAxis];
    
    float xValue = (smallestX - [self originHorizontalOffset])/[self horizontalScaleFactor] + [self minValueOnHorizontalAxis];
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:xValue];
    NSString *dateString, *valueString, *displayString;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM"];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:0];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    
    valueString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:yValue]];
    
    dateString = [dateFormatter stringFromDate:date];
    //valueString = [[NSNumber numberWithFloat:yValue] stringValue];
    
    
    displayString = [[[[[[MetasomeDataPointStore sharedStore] toGraph] stringByAppendingString:@": "] stringByAppendingString:valueString] stringByAppendingString:@" on "] stringByAppendingString:dateString];
    
    // Must set view to first responder in order to use UIMenu
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *infoItem = [[UIMenuItem alloc] initWithTitle:displayString action:@selector(hideMenu)];
    [menu setMenuItems:[NSArray arrayWithObject:infoItem]];
    [menu setTargetRect:CGRectMake(smallestX, smallestY, 2, 2) inView:self];
    [menu setMenuVisible:YES animated:YES];
    
    [self setNeedsDisplay];
    NSLog(@"Touch at %@, %f", dateString, yValue);
}

-(float)distanceBetweenPoint:(CGPoint)pointOne andPoint:(CGPoint)pointTwo
{
    float xDist = (pointOne.x - pointTwo.x)*(pointOne.x - pointTwo.x);
    float yDist = (pointOne.y - pointTwo.y)*(pointOne.y - pointTwo.y);
    
    //float distance = sqrt( pow(abs(pointOne.x - pointTwo.x), 2) + pow(abs(pointOne.y - pointTwo.y), 2) );
    //float distance =
    float distance = sqrtf(xDist + yDist);
    
    return distance;

}
-(void)initializeGraphView
{

    NSString *n = [[[MetasomeDataPointStore sharedStore] parameterToGraph] parameterName];
    NSDate *from = [[MetasomeDataPointStore sharedStore] since];
    NSDate *to = [NSDate date];
    
    pointsToGraph = [[NSMutableArray alloc] initWithArray:[[MetasomeDataPointStore sharedStore] pointsWithParameterName:n fromDate:from toDate:to]];

    [self setScale:pointsToGraph];
    [self convertDataPointsToCoordinates:pointsToGraph];

    CGPoint here = CGPointMake([self originHorizontalOffset] + [self horizontalAxisLength] + 40, [self topBuffer]);
    

    

}

/* convertDataPointsToCoordinates takes a mutable array of 
 MetasomeDataPoints as an argument, iteratively converts the 
 points into an array of CGPoints, and returns this array. 
 -Note: Call this method only after calling initializeGraphView
*/
-(void)convertDataPointsToCoordinates:(NSMutableArray *)dataPoints
{
    dataPointCoordinates = [[NSMutableArray alloc] init];
    
    float horizontalPos, verticalPos;

    for (MetasomeDataPoint *p in dataPoints) {

        horizontalPos = ( [p pDate]  - [self minValueOnHorizontalAxis]) * [self horizontalScaleFactor] + [self originHorizontalOffset];
        verticalPos = ([p parameterValue] - [self minValueOnVerticalAxis]) * [self verticalScaleFactor] ;
        
        verticalPos = [self scrollViewHeight] - verticalPos - [self originVerticalOffset];
        
        // Adjust points' location based on size
        verticalPos -= POINT_HEIGHT/2;
        horizontalPos -= POINT_WIDTH/2;
        
        CGPoint point = CGPointMake(horizontalPos, verticalPos);
        
        [dataPointCoordinates addObject:[NSValue valueWithCGPoint:point]];
    }
        /* to retrieve the value of the point:
       CGPoint b = [(NSValue *)[array objectAtIndex:0] CGPointValue];
        */
                               
}

-(void)drawRect:(CGRect)rect
{

    [self setCtx: UIGraphicsGetCurrentContext()];
    [self setTransform:CGAffineTransformConcat(CGContextGetTextMatrix([self ctx]), CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0))];
    
    [self drawAxes];
    [self graphPoints:[self pointsToGraph]];
    
    CGPoint here = CGPointMake([self originHorizontalOffset] + [self horizontalAxisLength] + 40, [self topBuffer]);
    
    legend = [[Legend alloc] initWithContext:[self ctx] withTransformation:[self transform] atPoint:here];
    
    [legend drawBackground];
    [legend drawLabels];
    [legend setMinValueOnHorizontalAxis:[self minValueOnHorizontalAxis]];
    [legend setMinValueOnVerticalAxis:[self minValueOnVerticalAxis]];
    [legend setHorizontalScaleFactor:[self horizontalScaleFactor]];
    [legend setVerticalScaleFactor:[self verticalScaleFactor]];
    [legend setOriginHorizontalOffset:[self originHorizontalOffset]];
    [legend setOriginVerticalOffset:[self originVerticalOffset]];
    [legend setScrollViewHeight:[self scrollViewHeight]];
    [legend setSince:[[[MetasomeDataPointStore sharedStore] since] timeIntervalSince1970]];
    [legend setTopBuffer:topBuffer];
    [legend setVerticalAxisLength:verticalAxisLength];
    
    [legend connectTheDots:[self pointsToGraph]];
    
    //[self drawEventLabels];
    
    //legend = nil;
    parentGraphViewController = nil;
}


-(void)graphPoints:(NSArray *)array

{
    [self setScale:pointsToGraph];
    
    CGRect drawInMe;
    float radius = 1.0;
    float red, green, blue;
    
    CGContextSetLineWidth([self ctx], radius);
    CGContextSetRGBStrokeColor([self ctx], 1.0, 0.0, 0.0, 0.5);
    //CGContextSetRGBFillColor([self ctx], 1.0, 0.0, 0.0, 0.50);
        
    float horizontalPos, verticalPos;
    
    for (MetasomeDataPoint *p in array) {
        
            red = [p red];
            green = [p green];
            blue = [p blue];
        
            CGContextSetRGBFillColor([self ctx], red, green, blue, 0.7);
            
            horizontalPos = ( [p pDate]  - [self minValueOnHorizontalAxis]) * [self horizontalScaleFactor] + [self originHorizontalOffset];
            verticalPos = ([p parameterValue] - [self minValueOnVerticalAxis]) * [self verticalScaleFactor] ;
        
            verticalPos = [self scrollViewHeight] - verticalPos - [self originVerticalOffset];
        
            // Adjust points' location based on size
            verticalPos -= POINT_HEIGHT/2;
            horizontalPos -= POINT_WIDTH/2;
        
            drawInMe = CGRectMake(horizontalPos, verticalPos, POINT_WIDTH, POINT_HEIGHT);
            CGContextAddEllipseInRect([self ctx], drawInMe);
            
            CGContextFillPath([self ctx]);
    }
    
}

-(void)generateAxisLabels
{
    
}

-(void)drawAxes
{
    // Draw horizontal axis line
    CGPoint begin = CGPointMake([self originHorizontalOffset], [self scrollViewHeight] - [self originVerticalOffset]);
    CGPoint end = CGPointMake([self scrollViewWidth] - [self rightBuffer] , begin.y);
    
    // Draw horizontal axis line
    CGContextSetLineWidth([self ctx], 3.0);
    CGContextSetLineCap([self ctx], kCGLineCapRound);
    CGContextSetRGBStrokeColor([self ctx], 0, 0, 0, 1);
    CGContextMoveToPoint([self ctx], begin.x, begin.y);
    CGContextAddLineToPoint([self ctx], end.x, end.y);
    
    
    begin = CGPointMake([self originHorizontalOffset], [self scrollViewHeight] - [self originVerticalOffset]);
    end = CGPointMake([self originHorizontalOffset], [self topBuffer]);
    
    //CGPoints used for drawing grid lines
    CGPoint beginGrid, endGrid;
    
    //Step size while drawing axes
    float horizontalStep = [self horizontalAxisLength] / HORIZONTAL_NUMBER_OF_INTERVALS;
    float verticalStep = [self verticalAxisLength] / VERTICAL_NUMBER_OF_INTERVALS;
    
    float valueStep = ([self maxValueOnVerticalAxis] - [self minValueOnVerticalAxis]) / VERTICAL_NUMBER_OF_INTERVALS;
    float dateStep = ([self maxValueOnHorizontalAxis] - [self minValueOnHorizontalAxis]) / HORIZONTAL_NUMBER_OF_INTERVALS;

    //Draw axes and change line width before drawing grid lines
    CGContextStrokePath([self ctx]);
    CGContextSetLineWidth([self ctx], 0.5);
    CGContextSetRGBStrokeColor([self ctx], 0, 0, 0, 0.5);
    CGContextSetRGBFillColor([self ctx], 1.0, 0, 0, 0.2);
    
    float dateCounter = 1;
    float horizontalValue = [self minValueOnHorizontalAxis];
    float x;

    
    // Draw vertical grid lines
    for (
         x = [self originHorizontalOffset] + horizontalStep; x < ( [self scrollViewWidth]  - [self rightBuffer] ); x += horizontalStep )
    {
        beginGrid = CGPointMake(x, [self scrollViewHeight] - [self originVerticalOffset]);
        endGrid = CGPointMake(x, [self topBuffer]);
        CGContextMoveToPoint([self ctx], beginGrid.x, beginGrid.y);
        CGContextAddLineToPoint([self ctx], endGrid.x, endGrid.y);
        
        dateCounter +=1;
        
    }

    // Draw horizontal grid lines
    float valueCounter = 1;
    float verticalValue = [self minValueOnVerticalAxis];
    
    for (float y = [self scrollViewHeight] - [self originVerticalOffset] - verticalStep; y > [self topBuffer]; y -= verticalStep)
    {
        beginGrid = CGPointMake( [self originHorizontalOffset], y );
        endGrid = CGPointMake( [self scrollViewWidth] - [self rightBuffer], y);
        CGContextMoveToPoint([self ctx], beginGrid.x, beginGrid.y);
        CGContextAddLineToPoint([self ctx], endGrid.x, endGrid.y);
        verticalValue = [self minValueOnVerticalAxis] + (valueCounter * valueStep);
        
        valueCounter += 1;
    }
    
    CGContextStrokePath([self ctx]);
    
}


-(void)willRemoveSubview:(UIView *)subview
{
    
    [super removeFromSuperview];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
-(void)hideMenu
{

}
-(void)setScale:(NSArray *)array
{    
    [self setMaxValueOnHorizontalAxis:[[NSDate date] timeIntervalSince1970]];
    //minValueOnHorizontalAxis set via NSDate *since, which is set in GraphViewController
    [self setMinValueOnHorizontalAxis:[[[MetasomeDataPointStore sharedStore] since] timeIntervalSince1970]];
    [self setMinValueOnVerticalAxis:1000.0];
    [self setMaxValueOnVerticalAxis:0];
    
    for (MetasomeDataPoint *p in array) {
        //Looking only for points of interest
        if ( [ [p parameterName] isEqualToString:[[MetasomeDataPointStore sharedStore] toGraph] ] ) {
                        
            if ([p parameterValue] > [self maxValueOnVerticalAxis]) {
                [self setMaxValueOnVerticalAxis:[p parameterValue]];
            }
            if ([p parameterValue] < [self minValueOnVerticalAxis]) {
                [self setMinValueOnVerticalAxis:[p parameterValue]];
            }

        }
    }
    
    // In case of only one data point...
    if ( [self minValueOnVerticalAxis] == [self maxValueOnVerticalAxis])
        [self setMinValueOnVerticalAxis:0];
    
    // Add slack to the vertical and horizontal axes
   // maxValueOnVerticalAxis += 0.2*(maxValueOnVerticalAxis - minValueOnVerticalAxis);
    //maxValueOnHorizontalAxis += 0.2*(maxValueOnHorizontalAxis - minValueOnHorizontalAxis);
    //minValueOnVerticalAxis -= 0.3*(maxValueOnVerticalAxis - minValueOnVerticalAxis);
    
    if (minValueOnVerticalAxis < 0)
        minValueOnVerticalAxis = 0;
    
    CGPoint begin = CGPointMake([self originHorizontalOffset], [self scrollViewHeight] - [self originVerticalOffset]);
    CGPoint end = CGPointMake([self scrollViewWidth] - [self rightBuffer] , begin.y);
    
    [self setHorizontalAxisLength:abs(end.x - begin.x)];
    
    end = CGPointMake([self originHorizontalOffset], [self topBuffer]);
    [self setVerticalAxisLength:(begin.y - end.y)];

    [self setHorizontalScaleFactor:([self horizontalAxisLength] / ([self maxValueOnHorizontalAxis] - [self minValueOnHorizontalAxis])) ];
    [self setVerticalScaleFactor:([self verticalAxisLength] / ([self maxValueOnVerticalAxis] - [self minValueOnVerticalAxis])) ];
    
}



@end
