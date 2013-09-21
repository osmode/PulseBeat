//
//  HoveringLabel.m
//  Metasome
//
//  Created by Omar Metwally on 9/16/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "HoveringLabel.h"

@implementation HoveringLabel
@synthesize label, initialPoint;

-(id)initWithLabel:(UILabel *)newLabel point:(CGPoint)pt
{
    self = [super init];
    if (self) {
        [self setLabel:newLabel];
        [self setInitialPoint:pt];
    }
    return self;
}
@end
