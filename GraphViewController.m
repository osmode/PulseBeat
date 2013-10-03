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
#import "MetasomeEvent.h"
#import "Legend.h"
#import "MetasomeParameter.h"
#import "HoveringLabel.h"

@implementation GraphViewController

UISegmentedControl *segmentControl;
float const VERTICAL_AXIS_BACKGROUND_WIDTH = 50;
float const VERTICAL_AXIS_BACKGROUND_HEIGHT = 330;
float const SCROLL_VIEW_CORRECTION_FACTOR = 64.0;

// hovering labels are the vertical axis labels as UILabels

float const VERTICAL_INTERVALS = 10.0;
float const HOVERING_AXIS_LABEL_WIDTH = 35;
float const HOVERING_AXIS_LABEL_HEIGHT = 20;
float const HOVERING_AXIS_LABEL_X_OFFSET = -35;
float const HOVERING_AXIS_LABEL_Y_OFFSET = -10;

@synthesize ctx, verticalAxisLine, verticalAxisBackground, verticalAxisBackgroundX, verticalAxisBackgroundY, verticalAxisBackgroundWidth, verticalAxisBackgroundHeight;
@synthesize hoveringLabels, titleLabel, hoveringVerticalAxisLine;
@synthesize hoveringHorizontalLabels;
@synthesize graphView, hoveringVerticalLabels, allEventLabels;


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
        //titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:15.0];
        [titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        
        verticalAxisLine = [[UILabel alloc] initWithFrame:CGRectZero];
        verticalAxisLine.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        hoveringVerticalAxisLine = [[HoveringLabel alloc] initWithLabel:verticalAxisLine point:verticalAxisLine.frame.origin];
        hoveringHorizontalLabels = [[NSMutableArray alloc] init];
        hoveringVerticalLabels = [[NSMutableArray alloc] init];
        
        allEventLabels = [[NSMutableArray alloc] init];
        

    }
    
    return self;
}

-(void)addTitle
{
    [titleLabel removeFromSuperview];
    [titleLabel setText:[graphView graphTitle]];
    [[titleLabel layer] setDrawsAsynchronously:YES];
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

-(void)drawVerticalAxisBackground
{
    
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 0.0, graphView.originHorizontalOffset, graphView.scrollViewHeight)];
    //backgroundLabel.backgroundColor = [UIColor whiteColor];
    backgroundLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    backgroundLabel.layer.zPosition = 10.0;

    HoveringLabel *hoveringBackgroundLabel = [[HoveringLabel alloc] initWithLabel:backgroundLabel point:backgroundLabel.frame.origin];
    
    [hoveringLabels addObject:hoveringBackgroundLabel];
    [backgroundLabel removeFromSuperview];
    [scrollView addSubview:backgroundLabel];
    
}

-(void)loadView
{
    // set scale to last week's points by default
    float interval = [[NSDate date] timeIntervalSince1970] - 604800;
    NSDate *oneWeekAgo = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
    [[MetasomeDataPointStore sharedStore] setSince:oneWeekAgo];
    
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
    
    [self drawVerticalAxisBackground];

    [graphView generateAxisLabels];
    [self generateHorizontalAxisLabels];
    [self drawHorizontalAxisLabels];
    [self drawVerticalAxisLabels];
    
    [self addTitle];
    [self addVerticalAxisLine];


    NSArray *itemArray = [NSArray arrayWithObjects:@"Week", @"Month", @"3 mo", @"1 yr", nil];
    segmentControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    //segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentControl.selectedSegmentIndex = 0;
    [segmentControl addTarget:self action:@selector(changeInterval) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentButton = [[UIBarButtonItem alloc] initWithCustomView:segmentControl];
    self.navigationItem.rightBarButtonItem = segmentButton;
    
    
    //new addition
    [graphView initializeGraphView];
    [self generateEventLabels:[[MetasomeEventStore sharedStore] allEvents]];
    [self drawEventLabels];
    
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
    date = nil;
    
    // must re-initialize graphView
    [graphView initializeGraphView];
    [graphView setParentGraphViewController:self];
    
    // clear graphView's horizontal axis labels
    [hoveringHorizontalLabels makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    
    // clear event labels
    [allEventLabels makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    
    [self generateHorizontalAxisLabels];
    [self drawHorizontalAxisLabels];
    [self generateEventLabels:[[MetasomeEventStore sharedStore] allEvents]];
    [self drawEventLabels];
    
    [graphView setNeedsDisplay];
    [scrollView setNeedsDisplay];
    
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
    
    // print out contentInset/Offset
   // NSLog(@"content: %f", scrollView.contentOffset.x);
    
    
}
    
-(void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    [titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [graphView setNeedsLayout];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [scrollView setContentOffset:CGPointMake(640.0, 0)];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
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

-(void)drawVerticalAxisLabels
{
    
    CGPoint begin = CGPointMake([graphView originHorizontalOffset], [graphView scrollViewHeight] - [graphView originVerticalOffset]);
    CGPoint end = CGPointMake([graphView originHorizontalOffset], [graphView topBuffer]);
    
    //CGPoints used for drawing grid lines
    CGPoint beginGrid, endGrid;
    
    [graphView setVerticalAxisLength:(begin.y - end.y)];
    
    //Step size while drawing axes
    float verticalStep = [graphView verticalAxisLength] / VERTICAL_INTERVALS;
    
    float valueStep = ([graphView maxValueOnVerticalAxis] - [graphView minValueOnVerticalAxis]) / VERTICAL_INTERVALS;
    

    // Draw horizontal grid lines
    float valueCounter = 1;
    float verticalValue = [graphView minValueOnVerticalAxis];
    
    NSString *verticalDisplay;
    
    for (float y = [graphView scrollViewHeight] - [graphView originVerticalOffset] - verticalStep; y > [graphView topBuffer]; y -= verticalStep)
    {
        beginGrid = CGPointMake( [graphView originHorizontalOffset], y );
        endGrid = CGPointMake( [graphView scrollViewWidth] - [graphView rightBuffer], y);
        
        verticalValue = [graphView minValueOnVerticalAxis] + (valueCounter * valueStep);
        
        // if input is an integer type (e.g. from a slider), get rid of decimal places
        if ([[[MetasomeDataPointStore sharedStore] parameterToGraph] inputType] == ParameterInputSlider || [[[MetasomeDataPointStore sharedStore] parameterToGraph] inputType] == ParameterInputInteger || [[[MetasomeDataPointStore sharedStore] parameterToGraph] inputType] == ParameterBloodPressure) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setMaximumFractionDigits:0];
            [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
            verticalDisplay = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:verticalValue]];
        } else {
            verticalDisplay = [NSString localizedStringWithFormat:@"%.1F", verticalValue];
        }
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(beginGrid.x + HOVERING_AXIS_LABEL_X_OFFSET, beginGrid.y + HOVERING_AXIS_LABEL_Y_OFFSET, HOVERING_AXIS_LABEL_WIDTH, HOVERING_AXIS_LABEL_HEIGHT)];
        
        l.text = verticalDisplay;
        l.textColor = [UIColor blackColor];
        l.backgroundColor = [UIColor clearColor];
        l.font = [UIFont systemFontOfSize:20.0];
        l.adjustsFontSizeToFitWidth = YES;
        l.layer.zPosition = 15;
        l.layer.drawsAsynchronously = YES;
        
        HoveringLabel *newLabel = [[HoveringLabel alloc] initWithLabel:l point:l.frame.origin];
        
        [scrollView addSubview:l];
        [hoveringVerticalLabels addObject:l];
        
        [hoveringLabels addObject:newLabel];
        
        l = nil;
        newLabel = nil;
        
        
        valueCounter += 1;
    }
    
}

-(void)generateHorizontalAxisLabels
{
    int lastDay = 0;
    
    // clear hoveringHorizontalLabels array before (re-)populating it
    [hoveringHorizontalLabels removeAllObjects];
    
    CGPoint begin = CGPointMake([graphView originHorizontalOffset], [graphView scrollViewHeight] - [graphView originVerticalOffset]);
    CGPoint end = CGPointMake([graphView originHorizontalOffset], [graphView topBuffer]);
    
    //CGPoints used for drawing grid lines
    CGPoint beginGrid, endGrid;
    
    //[self setVerticalAxisLength:(begin.y - end.y)];
    
    //Step size while drawing axes
    float horizontalStep = [graphView horizontalAxisLength] / 20.0;
    
    float dateStep = ([graphView maxValueOnHorizontalAxis] - [graphView minValueOnHorizontalAxis]) / 20.0;
    
    
    float dateCounter = 1;
    float horizontalValue = [graphView minValueOnHorizontalAxis];
    float x;
    NSDate *runningDate;
    NSString *horizontalDisplay;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    
    for (
         x = [graphView originHorizontalOffset] + horizontalStep; x < ( [graphView scrollViewWidth]  - [graphView rightBuffer] ); x += horizontalStep )
    {
        beginGrid = CGPointMake(x, [graphView scrollViewHeight] - [graphView originVerticalOffset]);
        endGrid = CGPointMake(x, [graphView topBuffer]);
        
        horizontalValue = [graphView minValueOnHorizontalAxis] + (dateCounter * dateStep);
        runningDate = [NSDate dateWithTimeIntervalSince1970:horizontalValue];
        
        
        NSDate *currentDate = runningDate;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components
        
        horizontalDisplay = [dateFormatter stringFromDate:runningDate];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(beginGrid.x - (30.0 / 2.0), beginGrid.y, 50.0, 50.0)];
        dateLabel.text = horizontalDisplay;
        
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        //dateLabel.font = [UIFont systemFontOfSize:20.0];
        dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        dateLabel.adjustsFontSizeToFitWidth = YES;
        dateLabel.layer.drawsAsynchronously = YES;
        dateLabel.layer.zPosition = 5;
        
        // rotate the date label
        dateLabel.transform = CGAffineTransformMakeRotation(M_PI_4);
        
        [hoveringHorizontalLabels addObject:dateLabel];
        
        
       // NSLog(@"day: %i, lastDay = %i", [components day], lastDay);
        if (lastDay == [components day]) {
            //NSLog(@"equal");
        }
        else {
            lastDay = [components day];
            dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
           // NSLog(@"not equal");
        }
        
        dateLabel = nil;
        dateCounter +=1;
        
    }
    
}


-(void)generateEventLabels:(NSArray *)events
{
    
    float horizontalPos, verticalPos;
    [allEventLabels removeAllObjects];
    
    for (MetasomeEvent *ev in events) {
        if ([[ev date] timeIntervalSince1970] > [[[MetasomeDataPointStore sharedStore] since] timeIntervalSince1970] && [ev visible]) {
            
            horizontalPos = ([[ev date] timeIntervalSince1970] - [graphView minValueOnHorizontalAxis]) * [graphView horizontalScaleFactor] + [graphView originHorizontalOffset];
            
            horizontalPos -= graphView.verticalAxisLength / 2.0;
            verticalPos = graphView.scrollViewHeight - graphView.originVerticalOffset - graphView.verticalAxisLength/2.0;
            verticalPos -= 15;
            
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalPos, verticalPos, [graphView verticalAxisLength], 30.0)];
            
            //eventLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
            eventLabel.backgroundColor = [UIColor colorWithRed:0.65 green:0.51 blue:0.93 alpha:0.5];
            
            eventLabel.layer.cornerRadius = 5;
            [eventLabel.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
            
            [eventLabel.layer setBorderWidth:1.0];
            [eventLabel setText:[ev title]];
            [eventLabel setTextAlignment:NSTextAlignmentCenter];
            [eventLabel setTextColor:[UIColor whiteColor]];
            [eventLabel setAdjustsFontSizeToFitWidth:YES];
            
            eventLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
            eventLabel.layer.drawsAsynchronously = YES;
            
            [allEventLabels addObject:eventLabel];
            eventLabel = nil;

        }
    }
    
}

-(void)removeEventLabels
{
    [allEventLabels makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
}

-(void)drawEventLabels
{
    for (UILabel *l in allEventLabels) {
        [scrollView addSubview:l];
        
    }
}


@end
