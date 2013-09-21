//
//  HoveringLabel.h
//  Metasome
//
//  Created by Omar Metwally on 9/16/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HoveringLabel : NSObject

@property (nonatomic, strong) UILabel *label;
@property CGPoint initialPoint;

-(id)initWithLabel:(UILabel *)newLabel point:(CGPoint)pt;

@end
