//
//  AxisView.h
//  Metasome
//
//  Created by Omar Metwally on 9/16/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AxisView : UIView
{
    
}

@property (nonatomic) CGContextRef ctx;
@property (nonatomic) CGAffineTransform transform;

-(void)drawText:(NSString *)writeMe fontSize:(float)size horizontalLocation:(float)horizonal verticalLocation:(float)vertical rotation:(float)radians;


@end
