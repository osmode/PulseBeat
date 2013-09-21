//
//  Legend.h
//  Metasome
//
//  Created by Omar Metwally on 9/3/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Legend : NSObject
{
    
}

@property (nonatomic) CGPoint upperLeftCorner;
@property (nonatomic) CGContextRef context;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) float minValueOnHorizontalAxis, minValueOnVerticalAxis, horizontalScaleFactor, verticalScaleFactor, originHorizontalOffset, originVerticalOffset, scrollViewHeight;

-(id)initWithContext:(CGContextRef)ctx withTransformation:(CGAffineTransform)tf atPoint:(CGPoint)point;
-(void)drawBackground;
-(void)drawLabels;
-(void)drawText:(NSString *)writeMe fontSize:(float)size horizontalLocation:(float)horizonal verticalLocation:(float)vertical rotation:(float)radians;
-(void)connectTheDots:(NSMutableArray *)allPoints;


@end
