//
//  LineView.m
//  Metasome
//
//  Created by Omar Metwally on 9/16/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "LineView.h"

@implementation LineView
@synthesize startPoint, endPoint, initialOrigin;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 5.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.5);
    
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, startPoint.x, startPoint.y);
    
    CGContextStrokePath(context);    
    
}


@end
