//
//  AxisView.m
//  Metasome
//
//  Created by Omar Metwally on 9/16/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "AxisView.h"

@implementation AxisView

@synthesize  ctx, transform;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setCtx:UIGraphicsGetCurrentContext()];
        [self setTransform:CGAffineTransformConcat(CGContextGetTextMatrix([self ctx]), CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0))];
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [self setCtx:UIGraphicsGetCurrentContext()];
    [self drawText:@"Test" fontSize:20.0 horizontalLocation:100 verticalLocation:100 rotation:0.0];
}

-(void)drawText:(NSString *)writeMe fontSize:(float)size horizontalLocation:(float)horizonal verticalLocation:(float)vertical rotation:(float)radians
{
    [self setCtx:UIGraphicsGetCurrentContext()];
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

@end
