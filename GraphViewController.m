//
//  GraphViewController.m
//  Metasome
//
//  Created by Omar Metwally on 8/21/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "MetasomeDataPointStore.h"
#import "AxisView.h"
#import "HoveringLabel.h"
#import "LineView.h"

@implementation GraphViewController
UISegmentedControl *segmentControl;
float const VERTICAL_AXIS_BACKGROUND_WIDTH = 50;
float const VERTICAL_AXIS_BACKGROUND_HEIGHT = 330;
float const SCROLL_VIEW_CORRECTION_FACTOR = 64.0;

@synthesize underView, ctx, verticalAxisLine, verticalAxisBackground, verticalAxisBackgroundX, verticalAxisBackgroundY, verticalAxisBackgroundWidth, verticalAxisBackgroundHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        verticalAxisLine = [[LineView alloc] init];
    }
    return self;
}

-(void)loadView
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(test:)];
    [[[self navigationController] navigationItem] setRightBarButtonItem:item];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGRect test = CGRectMake(0, 0, 50, 50);
    scrollView = [[UIScrollView alloc] initWithFrame:frame];

    //[self setView: scrollView];
    
    CGRect bigRect;
    bigRect.size.width = frame.size.width*3;
    bigRect.size.height = frame.size.height * 0.75;
    
    underView = [[UIView alloc] initWithFrame:test];
    underView.backgroundColor = [UIColor redColor];
    
    [self setView:scrollView];

    graphView = [[GraphView alloc] initWithFrame:bigRect];
    [graphView setParentContext:UIGraphicsGetCurrentContext()];
    
    [graphView setUnderViewPointer:underView];

    scrollView.delegate = self;
    
    [graphView setScrollViewWidth:bigRect.size.width];
    [graphView setScrollViewHeight:bigRect.size.height];

    [graphView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [graphView setMinimumZoomScale:1.0];
    [graphView setMaximumZoomScale:5.0];
    
    [underView addSubview:scrollView];
    [scrollView addSubview:graphView];
    [scrollView setContentSize:bigRect.size];
    
        
    NSArray *itemArray = [NSArray arrayWithObjects:@"Week", @"Month", @"3 mo", @"1 yr", nil];
    segmentControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    //segmentControl.frame = CGRectMake(35, 200, 250, 50);
    segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentControl.selectedSegmentIndex = 0;
    
    [segmentControl addTarget:self action:@selector(changeInterval) forControlEvents:UIControlEventValueChanged];
    
    float interval = [[NSDate date] timeIntervalSince1970] - 604800;
    
    NSDate *oneWeekAgo = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
    
    [[MetasomeDataPointStore sharedStore] setSince:oneWeekAgo]; 
            
    UIBarButtonItem *segmentButton = [[UIBarButtonItem alloc] initWithCustomView:segmentControl];
    self.navigationItem.rightBarButtonItem = segmentButton;
    
}

-(void)changeInterval
{
    int index = ( [segmentControl selectedSegmentIndex] );
    NSDate *date;
        
    switch(index)
    {
        //Graph last week
        case 0:
            date =[[NSDate alloc] initWithTimeIntervalSince1970:( [[NSDate date] timeIntervalSince1970] - 604800)];
            break;
            
        //Graph last month
        case 1:
            date =[[NSDate alloc] initWithTimeIntervalSince1970:( [[NSDate date] timeIntervalSince1970] - 2.62974e6)];

            break;
        //Graph last 3 months
        case 2:
            date =[[NSDate alloc] initWithTimeIntervalSince1970:( [[NSDate date] timeIntervalSince1970] - 7.88923e6)];

            break;
        //Graph last year
        case 3:
            date =[[NSDate alloc] initWithTimeIntervalSince1970:( [[NSDate date] timeIntervalSince1970] - 3.15569e7)];
            break;
        default:
            NSLog(@"Invalid segmented bar selection.");
    }
    
    [[MetasomeDataPointStore sharedStore] setSince:date];
    [graphView setNeedsDisplay];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    
    for (HoveringLabel *hl in [graphView hoveringLabels]) {
        CGRect fixedFrame = hl.label.frame;
        fixedFrame.origin.x = hl.initialPoint.x + scrollView.contentOffset.x;
        fixedFrame.origin.y = hl.initialPoint.y + scrollView.contentOffset.y;
        fixedFrame.origin.y += SCROLL_VIEW_CORRECTION_FACTOR;
        hl.label.frame = fixedFrame;
    }
    
    //LineView *lv = [[LineView alloc] init];
    //lv = [graphView hoveringVerticalLine];
    CGRect fixedFrame2 = verticalAxisLine.frame;
    fixedFrame2.origin.x = verticalAxisLine.initialOrigin.x + scrollView.contentOffset.x;
    fixedFrame2.origin.y = verticalAxisLine.initialOrigin.y + scrollView.contentOffset.y;
    
    // the following line is to fix an iOS 7 UIScrollView bug
    fixedFrame2.origin.y += SCROLL_VIEW_CORRECTION_FACTOR;
    verticalAxisLine.frame = fixedFrame2;
    
    CGRect fixedFrame3 = verticalAxisBackground.frame;
    fixedFrame3.origin.x = [self verticalAxisBackgroundX] + scrollView.contentOffset.x;
    fixedFrame3.origin.y = [self verticalAxisBackgroundY] + scrollView.contentOffset.y;
    fixedFrame3.origin.y += SCROLL_VIEW_CORRECTION_FACTOR;
    verticalAxisBackground.frame = fixedFrame3;
    
}
    

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    // add background bar to UIScrollView
    [self setVerticalAxisBackgroundDimensions:[graphView hoveringLabels]];
    verticalAxisBackground = [[UIView alloc] initWithFrame:CGRectMake([self verticalAxisBackgroundX], [self verticalAxisBackgroundY], [self verticalAxisBackgroundWidth], [self verticalAxisBackgroundHeight])];
    
    // change to whiteColor in final version
    verticalAxisBackground.backgroundColor = [UIColor whiteColor];
    
    [scrollView addSubview:verticalAxisBackground];
    
    for (HoveringLabel *hl in [graphView hoveringLabels]) {
        [scrollView addSubview:hl.label];
    }
    
    [scrollView addSubview:anotherLabel];
    
    // add vertical axis line to UIScrollView
    verticalAxisLine = (UIView *)[graphView hoveringVerticalLine];
    [scrollView addSubview:verticalAxisLine];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return graphView;
}
-(void)test
{
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"View will disappear");
}
/* setVerticalAxisBackgroundDimensions takes an array of UILabels
  representing vertical axis labels as arguments */
-(void)setVerticalAxisBackgroundDimensions:(NSArray *)array
{
    
    [self setVerticalAxisBackgroundX:2000];
    [self setVerticalAxisBackgroundY:2000];
    
    // verticalAxisBackgroundX will be set to the UILabel with the
    // smallest x value
    // verticalAxisBackgroundY will be set to the UILabel with the
    // smallest y value 
    for (HoveringLabel *l in array) {
        
        if (l.label.frame.origin.y > 1.0) {
        if (l.label.frame.origin.x < [self verticalAxisBackgroundX])
            verticalAxisBackgroundX = l.label.frame.origin.x;
        if (l.label.frame.origin.y < [self verticalAxisBackgroundY])
            verticalAxisBackgroundY = l.label.frame.origin.y;
        }
        
        NSLog(@"Y = %f", l.label.frame.origin.y);
    }
    verticalAxisBackgroundX = 0.0;
    //verticalAxisBackgroundY -= 10.0;
    verticalAxisBackgroundY -= 20.0;
    
    [self setVerticalAxisBackgroundWidth:VERTICAL_AXIS_BACKGROUND_WIDTH];
    [self setVerticalAxisBackgroundHeight:VERTICAL_AXIS_BACKGROUND_HEIGHT];
}


@end
