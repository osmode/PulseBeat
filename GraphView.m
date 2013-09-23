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
float const VERTICAL_NUMBER_OF_INTERVALS = 10.0;
float const HORIZONTAL_NUMBER_OF_INTERVALS = 20.0;
float const AXIS_LABEL_FONTSIZE = 12.0;
//float const EVENT_BAR_WIDTH = 30.0;
float const EVENT_FONT_SIZE = 15.0;
float const ORIGIN_HORIZONTAL_OFFSET = 50.0;
float const ORIGIN_VERTICAL_OFFSET = 50.0;
float const VERTICAL_AXIS_LINE_WIDTH = 3.0;
float const TOP_BUFFER = 50;
float const RIGHT_BUFFER = 180;

// hovering labels are the vertical axis labels as UILabels
float const HOVERING_AXIS_LABEL_WIDTH = 35;
float const HOVERING_AXIS_LABEL_HEIGHT = 20;
float const HOVERING_AXIS_LABEL_X_OFFSET = -35;
float const HOVERING_AXIS_LABEL_Y_OFFSET = -10;

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


- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        //parentGraphViewController = [[GraphViewController alloc] init];
        
        [self setGraphTitle:[[[MetasomeDataPointStore sharedStore] toGraph] stringByAppendingString:@" vs time"]];
        
        [self initializeGraphView];
        
       }
    return self;
}

-(void)initializeGraphView
{

    [self setOriginHorizontalOffset:ORIGIN_HORIZONTAL_OFFSET];
    [self setOriginVerticalOffset:ORIGIN_VERTICAL_OFFSET];
    [self setTopBuffer:TOP_BUFFER];
    [self setRightBuffer:RIGHT_BUFFER];
    
    //The order in which these methods are called is critical!
    inputType = [[[MetasomeDataPointStore sharedStore] parameterToGraph] inputType];
    NSString *n = [[[MetasomeDataPointStore sharedStore] parameterToGraph] parameterName];
    NSDate *from = [[MetasomeDataPointStore sharedStore] since];
    NSDate *to = [NSDate date];
    
    pointsToGraph = [[NSMutableArray alloc] initWithArray:[[MetasomeDataPointStore sharedStore] pointsWithParameterName:n fromDate:from toDate:to]];

    [self setScale:pointsToGraph];

    //legend = [[Legend alloc] initWithContext:[self ctx] withTransformation:[self transform] atPoint:here];
    
}

-(void)drawRect:(CGRect)rect
{
    [self setCtx: UIGraphicsGetCurrentContext()];
    [self setTransform:CGAffineTransformConcat(CGContextGetTextMatrix([self ctx]), CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0))];
    
    [self drawAxes];
    
    [self graphPoints:[self pointsToGraph]];
    
    /*
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

    
    [parentScrollView setNeedsDisplay];
    
    [[MetasomeEventStore sharedStore] generateEventLabels:legend];
    [[MetasomeEventStore sharedStore] drawEvents:self];
    */
    
}

-(void)graphPoints:(NSArray *)array

{
    [self setScale:pointsToGraph];
    
    NSLog(@"minValueOnHorizontalAxis: %f", minValueOnHorizontalAxis);
    NSLog(@"horizontalScaleFactor: %f", horizontalScaleFactor);
    NSLog(@"verticalScaleFactor: %f", verticalScaleFactor);
    
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
    NSLog(@"since: %@", [[MetasomeDataPointStore sharedStore] since]);
    
    // clear both NSMutableArrays holding vertical and horizontal
    // axis labels in the parent view controller
    [[parentGraphViewController hoveringHorizontalLabels] removeAllObjects];
    [[parentGraphViewController hoveringLabels] removeAllObjects];
    
    
    CGPoint begin = CGPointMake([self originHorizontalOffset], [self scrollViewHeight] - [self originVerticalOffset]);
    CGPoint end = CGPointMake([self originHorizontalOffset], [self topBuffer]);
    
    //CGPoints used for drawing grid lines
    CGPoint beginGrid, endGrid;
    
    [self setVerticalAxisLength:(begin.y - end.y)];
    
    //Step size while drawing axes
    float horizontalStep = [self horizontalAxisLength] / HORIZONTAL_NUMBER_OF_INTERVALS;
    float verticalStep = [self verticalAxisLength] / VERTICAL_NUMBER_OF_INTERVALS;
    
    float valueStep = ([self maxValueOnVerticalAxis] - [self minValueOnVerticalAxis]) / VERTICAL_NUMBER_OF_INTERVALS;
    float dateStep = ([self maxValueOnHorizontalAxis] - [self minValueOnHorizontalAxis]) / HORIZONTAL_NUMBER_OF_INTERVALS;
    
    // Draw vertical grid lines

    float dateCounter = 1;
    float horizontalValue = [self minValueOnHorizontalAxis];
    float x;
    NSDate *runningDate;
    NSString *horizontalDisplay;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    
    for (
         x = [self originHorizontalOffset] + horizontalStep; x < ( [self scrollViewWidth]  - [self rightBuffer] ); x += horizontalStep )
    {
        beginGrid = CGPointMake(x, [self scrollViewHeight] - [self originVerticalOffset]);
        endGrid = CGPointMake(x, [self topBuffer]);
        
        horizontalValue = [self minValueOnHorizontalAxis] + (dateCounter * dateStep);
        runningDate = [NSDate dateWithTimeIntervalSince1970:horizontalValue];
        horizontalDisplay = [dateFormatter stringFromDate:runningDate];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(beginGrid.x - (HORIZONTAL_AXIS_LABEL_WIDTH / 2.0), beginGrid.y, HORIZONTAL_AXIS_LABEL_WIDTH, HORIZONTAL_AXIS_LABEL_HEIGHT)];
        dateLabel.text = horizontalDisplay;
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.backgroundColor = [UIColor redColor];
        dateLabel.font = [UIFont systemFontOfSize:20.0];
        dateLabel.adjustsFontSizeToFitWidth = YES;
        
        [[parentGraphViewController hoveringHorizontalLabels] addObject:dateLabel];
        dateLabel = nil;
        
        dateCounter +=1;
        
    }
    
    // Draw horizontal grid lines
    float valueCounter = 1;
    float verticalValue = [self minValueOnVerticalAxis];
    
    NSString *verticalDisplay;
    
    for (float y = [self scrollViewHeight] - [self originVerticalOffset] - verticalStep; y > [self topBuffer]; y -= verticalStep)
    {
        beginGrid = CGPointMake( [self originHorizontalOffset], y );
        endGrid = CGPointMake( [self scrollViewWidth] - [self rightBuffer], y);

        verticalValue = [self minValueOnVerticalAxis] + (valueCounter * valueStep);
        
        // if input is an integer type (e.g. from a slider), get rid of decimal places
        if (inputType == ParameterInputSlider || inputType == ParameterInputInteger || inputType == ParameterBloodPressure) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setMaximumFractionDigits:0];
            [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
            verticalDisplay = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:verticalValue]];
        } else {
            verticalDisplay = [NSString localizedStringWithFormat:@"%.1F", verticalValue];
        }
        
        //[self drawText:verticalDisplay fontSize:AXIS_LABEL_FONTSIZE horizontalLocation:(beginGrid.x - 60.0) verticalLocation:(beginGrid.y - 20.) rotation:0.0];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(beginGrid.x + HOVERING_AXIS_LABEL_X_OFFSET, beginGrid.y + HOVERING_AXIS_LABEL_Y_OFFSET, HOVERING_AXIS_LABEL_WIDTH, HOVERING_AXIS_LABEL_HEIGHT)];
        
        l.text = verticalDisplay;
        l.textColor = [UIColor blackColor];
        l.backgroundColor = [UIColor whiteColor];
        l.font = [UIFont systemFontOfSize:AXIS_LABEL_FONTSIZE];
        l.adjustsFontSizeToFitWidth = YES;
        l.layer.drawsAsynchronously = YES;
        
        HoveringLabel *newLabel = [[HoveringLabel alloc] initWithLabel:l point:l.frame.origin];
        [[parentGraphViewController hoveringLabels] addObject:newLabel];
        
        l = nil;
        
        // add to the 'hoveringLabels array in GraphViewController
        // GraphViewController handles drawing of labels
        
        valueCounter += 1;
    }
    
}

-(void)drawAxes
{
    
    CGPoint begin = CGPointMake([self originHorizontalOffset], [self scrollViewHeight] - [self originVerticalOffset]);
    CGPoint end = CGPointMake([self originHorizontalOffset], [self topBuffer]);
    
    //CGPoints used for drawing grid lines
    CGPoint beginGrid, endGrid;
    
    [self setVerticalAxisLength:(begin.y - end.y)];
    
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
    NSDate *runningDate;
    NSString *horizontalDisplay;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    
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


-(void)drawText:(NSString *)writeMe fontSize:(float)size horizontalLocation:(float)horizonal verticalLocation:(float)vertical rotation:(float)radians
{
    
    [self setTransform:CGAffineTransformRotate([self transform], radians)];
    CGContextSetTextMatrix([self ctx], [self transform]);
    
    CGContextSetRGBFillColor([self ctx], 0, 0, 0, 1);
    CGContextSelectFont([self ctx], "Helvetica", size, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing([self ctx], 1.0);
    CGContextSetTextDrawingMode([self ctx], kCGTextFill);
    
    CGContextShowTextAtPoint([self ctx], horizonal, vertical + size, [writeMe UTF8String], [writeMe length]);
    [self setTransform:CGAffineTransformRotate([self transform], -radians)];
    CGContextSetTextMatrix([self ctx], [self transform]);
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    /*
    CGPoint touched;
    
    // yValue and xValue are view coordinates converted into vertical axis values
    float xValue, yValue;
    
    for (UITouch *t in touches) {
        
        // Is this a double tap?
        if ([t tapCount] > 1) {
            return;
        }
        
        touched = [t locationInView:self];

        yValue = (touched.y + [self originVerticalOffset] - [self scrollViewHeight])/(-1*[self verticalScaleFactor]) + [self minValueOnVerticalAxis];
        
        xValue = (touched.x - [self originHorizontalOffset])/[self horizontalScaleFactor] + [self minValueOnHorizontalAxis];
        
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
        [menu setTargetRect:CGRectMake(touched.x, touched.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
        //[self setNeedsDisplay];
                                
        //NSLog(@"Touch at %@, %f", dateString, yValue);
    }
*/
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
    maxValueOnVerticalAxis += 0.2*(maxValueOnVerticalAxis - minValueOnVerticalAxis);
    maxValueOnHorizontalAxis += 0.2*(maxValueOnHorizontalAxis - minValueOnHorizontalAxis);
    minValueOnVerticalAxis -= 0.3*(maxValueOnVerticalAxis - minValueOnVerticalAxis);
    
    if (minValueOnVerticalAxis < 0)
        minValueOnVerticalAxis = 0;
    
    CGPoint begin = CGPointMake([self originHorizontalOffset], [self scrollViewHeight] - [self originVerticalOffset]);
    CGPoint end = CGPointMake([self scrollViewWidth] - [self rightBuffer] , begin.y);
    
    //[self setHorizontalAxisLength:abs(end.x - begin.x)];
    
    end = CGPointMake([self originHorizontalOffset], [self topBuffer]);
    [self setVerticalAxisLength:(begin.y - end.y)];

    [self setHorizontalScaleFactor:([self horizontalAxisLength] / ([self maxValueOnHorizontalAxis] - [self minValueOnHorizontalAxis])) ];
    [self setVerticalScaleFactor:([self verticalAxisLength] / ([self maxValueOnVerticalAxis] - [self minValueOnVerticalAxis])) ];
    
}



@end
