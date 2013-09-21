//
//  Legend.m
//  Metasome
//
//  Created by Omar Metwally on 9/3/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "Legend.h"
#import "MetasomeDataPoint.h"

@implementation Legend

@synthesize upperLeftCorner, transform;
@synthesize minValueOnHorizontalAxis, minValueOnVerticalAxis, horizontalScaleFactor, verticalScaleFactor, originHorizontalOffset, originVerticalOffset, scrollViewHeight;

-(id)initWithContext:(CGContextRef)ctx withTransformation:(CGAffineTransform)tf atPoint:(CGPoint)point;
{
    self = [super init];
    if (self) {
        [self setContext:ctx];
        [self setUpperLeftCorner:point];
        [self setTransform:tf];
        //CGAffineTransformMake already called once in GraphView
        /*
        [self setTransform:CGAffineTransformConcat(CGContextGetTextMatrix([self context]), CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0))];
         */
    
    }
    
    return self;
}
     
-(void)drawBackground
{
    CGRect drawInMe = CGRectMake([self upperLeftCorner].x, [self upperLeftCorner].y, 150, 200);
    CGContextSetRGBFillColor([self context], 0.54, 0.74, 0.91, 0.25);
    CGContextFillRect([self context], drawInMe);
    
}
-(void)drawLabels
{
    CGRect drawInMe = CGRectMake([self upperLeftCorner].x + 20, [self upperLeftCorner].y + 20, 20, 20);
    CGContextSetRGBFillColor([self context], 1.0, 0.0, 0.0, 1.0);
    CGContextAddEllipseInRect([self context], drawInMe);
    
    CGContextFillPath([self context]);
    
    [self drawText:@"4AM - 9AM" fontSize:15 horizontalLocation:drawInMe.origin.x + 25 verticalLocation:drawInMe.origin.y rotation:0];
    
    
    drawInMe = CGRectMake(drawInMe.origin.x, drawInMe.origin.y + 60, 20, 20);
    CGContextSetRGBFillColor([self context], 0.0, 1.0, 0.0, 1.0);
    CGContextAddEllipseInRect([self context], drawInMe);
    
    CGContextFillPath([self context]);
    
    [self drawText:@"9AM - 7PM" fontSize:15 horizontalLocation:drawInMe.origin.x + 25 verticalLocation:drawInMe.origin.y rotation:0];
    
    drawInMe = CGRectMake(drawInMe.origin.x, drawInMe.origin.y + 60, 20, 20);
    CGContextSetRGBFillColor([self context], 0.0, 0.0, 1.0, 1.0);
    CGContextAddEllipseInRect([self context], drawInMe);
    
    CGContextFillPath([self context]);
    
    [self drawText:@"7PM - 4AM" fontSize:15 horizontalLocation:drawInMe.origin.x + 25 verticalLocation:drawInMe.origin.y rotation:0];
    
    
}
-(void)drawText:(NSString *)writeMe fontSize:(float)size horizontalLocation:(float)horizonal verticalLocation:(float)vertical rotation:(float)radians
{

    [self setTransform:CGAffineTransformRotate([self transform], radians)];
    CGContextSetTextMatrix([self context], [self transform]);
    
    CGContextSetRGBFillColor([self context], 0, 0, 0, 1);
    CGContextSelectFont([self context], "Helvetica", size, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing([self context], 1.5);
    CGContextSetTextDrawingMode([self context], kCGTextFill);
    
    CGContextShowTextAtPoint([self context], horizonal, vertical + size, [writeMe UTF8String], [writeMe length]);
    [self setTransform:CGAffineTransformRotate([self transform], -radians)];
    CGContextSetTextMatrix([self context], [self transform]);
    
}

/* connectTheDots generates a connected line graph
   The argument must be an array ordered chronologically by date 

*/
-(void)connectTheDots:(NSMutableArray *)allPoints
{
    if ([allPoints count] <2)
        return;
    
    int numPoints = [allPoints count];
    int counter = 0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.9);
    CGPoint fromPoint = CGPointMake(0.0, 0.0);
    CGPoint toPoint = CGPointMake(0.0, 0.0);
    
    while (counter < (numPoints - 1) ) {
            MetasomeDataPoint *fromDataPoint = [allPoints objectAtIndex:counter];
            MetasomeDataPoint *toDataPoint = [allPoints objectAtIndex:(counter + 1)];
            
        // Don't iterate if we're already on the last point
        
        fromPoint.x = ( [fromDataPoint pDate]  - [self minValueOnHorizontalAxis]) * [self horizontalScaleFactor] + [self originHorizontalOffset];
        fromPoint.y = ([fromDataPoint parameterValue] - [self minValueOnVerticalAxis]) * [self verticalScaleFactor] ;
 
        toPoint.x = ( [toDataPoint pDate]  - [self minValueOnHorizontalAxis]) * [self horizontalScaleFactor] + [self originHorizontalOffset];
        toPoint.y = ([toDataPoint parameterValue] - [self minValueOnVerticalAxis]) * [self verticalScaleFactor] ;

        toPoint.y = [self scrollViewHeight] - toPoint.y - [self originVerticalOffset];
        
        fromPoint.y = [self scrollViewHeight] - fromPoint.y - [self originVerticalOffset];
        
        // Draw the lines
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
        CGContextStrokePath(context);
        
        counter += 1;

        
    }
}


@end
