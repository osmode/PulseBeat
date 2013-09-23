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
    UILabel *anotherLabel;
    HoveringLabel *titleHoveringLabel;
    
}

@property (nonatomic) CGContextRef ctx;
@property (nonatomic, strong) UILabel *verticalAxisBackground;
@property (nonatomic) float verticalAxisBackgroundX, verticalAxisBackgroundY, verticalAxisBackgroundWidth, verticalAxisBackgroundHeight;
@property (nonatomic, strong) NSMutableArray *hoveringLabels;
@property (nonatomic, strong) NSMutableArray *hoveringHorizontalLabels;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) HoveringLabel *titleHoveringLabel;
@property (nonatomic, strong) UILabel *verticalAxisLine;
@property (nonatomic, strong) HoveringLabel *hoveringVerticalAxisLine;
@property (nonatomic, strong) GraphView *graphView;


-(void)changeInterval;
-(void)initializeSubViews;
-(void)updateLabelPosition:(HoveringLabel *)hl withinScrollView:(UIScrollView *)sv;
-(void)addTitle;
-(void)drawHorizontalAxisLabels;

@end

