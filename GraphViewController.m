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
#import "MetasomeEventStore.h"


@implementation GraphViewController

UISegmentedControl *segmentControl;
float const VERTICAL_AXIS_BACKGROUND_WIDTH = 50;
float const VERTICAL_AXIS_BACKGROUND_HEIGHT = 330;
float const SCROLL_VIEW_CORRECTION_FACTOR = 64.0;

@synthesize ctx, verticalAxisLine, verticalAxisBackground, verticalAxisBackgroundX, verticalAxisBackgroundY, verticalAxisBackgroundWidth, verticalAxisBackgroundHeight;
@synthesize hoveringLabels, titleLabel, hoveringVerticalAxisLine;
@synthesize hoveringHorizontalLabels;
@synthesize graphView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        hoveringLabels = [[NSMutableArray alloc] init];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 200, 30)];
        titleHoveringLabel = [[HoveringLabel alloc] initWithLabel:titleLabel point:titleLabel.frame.origin];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = [graphView graphTitle];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:15.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        
        verticalAxisLine = [[UILabel alloc] initWithFrame:CGRectZero];
        verticalAxisLine.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        hoveringVerticalAxisLine = [[HoveringLabel alloc] initWithLabel:verticalAxisLine point:verticalAxisLine.frame.origin];
        
        hoveringHorizontalLabels = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addTitle
{
    [titleLabel removeFromSuperview];
    [titleLabel setText:[graphView graphTitle]];
    [scrollView addSubview:titleLabel];
}

-(void)addVerticalAxisLine
{
    [verticalAxisLine removeFromSuperview];
    [verticalAxisLine setFrame:CGRectMake([graphView originHorizontalOffset], [graphView topBuffer], 3.0, [graphView scrollViewHeight] - [graphView originVerticalOffset] - [graphView topBuffer])];
    
    [hoveringVerticalAxisLine setInitialPoint:verticalAxisLine.frame.origin];
    
    [scrollView addSubview:verticalAxisLine];
    
}

-(void)drawHorizontalAxisLabels
{
    for (UILabel *l in hoveringHorizontalLabels) {
        [l removeFromSuperview];
        [scrollView addSubview:l];
    }
}

-(void)drawVerticalAxisLabels
{
    for (HoveringLabel *hl in hoveringLabels) {
        [hl.label removeFromSuperview];
        [scrollView addSubview:hl.label];
    }
}

-(void)loadView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    
    CGRect bigRect;
    bigRect.size.width = frame.size.width*3;
    bigRect.size.height = frame.size.height * 0.75;
    
    [self setView:scrollView];

    graphView = [[GraphView alloc] initWithFrame:bigRect];
    [graphView setParentGraphViewController:self];
    scrollView.delegate = self;
    
    [graphView setScrollViewWidth:bigRect.size.width];
    [graphView setScrollViewHeight:bigRect.size.height];
    [graphView setHorizontalAxisLength:[graphView scrollViewWidth] - [graphView originHorizontalOffset] - [graphView rightBuffer]];

    [graphView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [graphView setMinimumZoomScale:1.0];
    [graphView setMaximumZoomScale:5.0];
    
    [scrollView addSubview:graphView];
    [scrollView setContentSize:bigRect.size];
    
    // after generateAxisLabels is called, GraphViewController's
    // arrays which hold the vertical & horizontal axis labels
    // are populated and ready to be drawn
    [graphView generateAxisLabels];
    [self drawHorizontalAxisLabels];
    [self drawVerticalAxisLabels];
    
    [self addTitle];
    [self addVerticalAxisLine];
    
    // set scale to last week's points by default
    float interval = [[NSDate date] timeIntervalSince1970] - 604800;
    NSDate *oneWeekAgo = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
    [[MetasomeDataPointStore sharedStore] setSince:oneWeekAgo];
    NSArray *itemArray = [NSArray arrayWithObjects:@"Week", @"Month", @"3 mo", @"1 yr", nil];
    segmentControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentControl.selectedSegmentIndex = 0;
    [segmentControl addTarget:self action:@selector(changeInterval) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentButton = [[UIBarButtonItem alloc] initWithCustomView:segmentControl];
    self.navigationItem.rightBarButtonItem = segmentButton;
    
}

-(void)changeInterval
{
    NSLog(@"Change interval called");
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
    
    /** New code **/
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    CGRect bigRect;
    bigRect.size.width = frame.size.width*3;
    bigRect.size.height = frame.size.height * 0.75;
    
    [graphView removeFromSuperview];
    graphView = nil;
    
    
    graphView = [[GraphView alloc] initWithFrame:bigRect];
    
    [graphView setScrollViewWidth:bigRect.size.width];
    [graphView setScrollViewHeight:bigRect.size.height];

    [graphView setHorizontalAxisLength:[graphView scrollViewWidth] - [graphView originHorizontalOffset] - [graphView rightBuffer]];

    
    [graphView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [graphView setMinimumZoomScale:1.0];
    [graphView setMaximumZoomScale:5.0];

    
    [scrollView addSubview:graphView];
    [scrollView setContentSize:bigRect.size];
    [graphView generateAxisLabels];
    [self drawHorizontalAxisLabels];
    [self drawVerticalAxisLabels];
    [scrollView addSubview:titleLabel];
    [scrollView addSubview:verticalAxisLine];
    
    
}
-(void)updateLabelPosition:(HoveringLabel *)hl withinScrollView:(UIScrollView *)sv
{
    CGRect fixedFrame = hl.label.frame;
    fixedFrame.origin.x = hl.initialPoint.x + sv.contentOffset.x;
    fixedFrame.origin.y = hl.initialPoint.y + sv.contentOffset.y;
    
    // iOS 7-specific change (navigation bars are now transparent)
    fixedFrame.origin.y += SCROLL_VIEW_CORRECTION_FACTOR;
    hl.label.frame = fixedFrame;
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    // remove all menus
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    
    [self updateLabelPosition:titleHoveringLabel withinScrollView:scrollView];
    [self updateLabelPosition:hoveringVerticalAxisLine withinScrollView:scrollView];
    
    
    
    for (HoveringLabel *hl in hoveringLabels) {
        
        [self updateLabelPosition:hl withinScrollView:scrollView];
        
    }
    
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
    
    if (self.isMovingFromParentViewController) {
        [self removeFromParentViewController];
    }
        
    [[self navigationController] popToRootViewControllerAnimated:YES];
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
        
    }
    verticalAxisBackgroundX = 0.0;
    //verticalAxisBackgroundY -= 10.0;
    verticalAxisBackgroundY -= 20.0;
    
    [self setVerticalAxisBackgroundWidth:VERTICAL_AXIS_BACKGROUND_WIDTH];
    [self setVerticalAxisBackgroundHeight:VERTICAL_AXIS_BACKGROUND_HEIGHT];
}

-(void)initializeSubViews
{
    
    
}


@end
