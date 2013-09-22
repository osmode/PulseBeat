//
//  GraphViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/21/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@class MetasomeParameter, LineView, HoveringLabel;

@interface GraphViewController : UIViewController <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    GraphView *graphView;
    UILabel *anotherLabel;
    HoveringLabel *titleHoveringLabel;
    
}

@property (nonatomic) UIView *underView;
@property (nonatomic) CGContextRef ctx;
@property (nonatomic, strong) LineView *verticalAxisLine;
@property (nonatomic, strong) UILabel *verticalAxisBackground;
@property (nonatomic) float verticalAxisBackgroundX, verticalAxisBackgroundY, verticalAxisBackgroundWidth, verticalAxisBackgroundHeight;

-(void)test;
-(void)changeInterval;
-(void)initializeSubViews;

@end
