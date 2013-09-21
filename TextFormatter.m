//
//  TextFormatter.m
//  Metasome
//
//  Created by Omar Metwally on 9/20/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "TextFormatter.h"

@implementation TextFormatter

+(void)formatTitleLabel:(UILabel *)label withTitle:(NSString *)title
{
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
}

@end
