//
//  DetailViewController_slider.m
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "DetailViewController_slider.h"
#import "MetasomeParameter.h"
#import "MetasomeDataPoint.h"
#import "MetasomeDataPointStore.h"
#import "GraphViewController.h"
#import "TextFormatter.h"
#import "MetasomeParameterStore.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"


@implementation DetailViewController_slider
@synthesize parameter, isDataPointStoreNonEmpty;
@synthesize smileyImage;
@synthesize lastPointSaved;

const int NUM_SLIDER_SECTIONS = 5;

-(id)init
{
    self = [super init];
    //lastPointSaved = [[MetasomeDataPoint alloc] init];
    
    return self;
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // initialize google tracking
    [self setScreenName:@"DetailViewController_slider"];
    
    [valueSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    
    initialColor = [graphButton backgroundColor];
    saveButton.layer.cornerRadius = 10.0;
    graphButton.layer.cornerRadius = 10.0;
    
    // change background colors when buttons are clicked
    
    [graphButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [graphButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    
    [saveButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [saveButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    
    // if this is a custom-made parameter, get rid of the smiley face
    if ([[self parameter] isCustomMade]) {
        
        [smileyImage setImage:nil];
    }
    
    smileyImage.layer.drawsAsynchronously = YES;
    graphButton.layer.drawsAsynchronously = YES;
    saveButton.layer.drawsAsynchronously = YES;
    
    // initially hide saluteLabel and saluteImage
    saluteLabel.hidden = YES;
    saluteImage.hidden = YES;
    saluteLabel.adjustsFontSizeToFitWidth = YES;
    
    [saluteImage setUserInteractionEnabled:YES];
    [saluteLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [saluteImage addGestureRecognizer:tap];
    [saluteLabel addGestureRecognizer:tap];
    [self.view addSubview:saluteImage];
    
}

-(void)tapped:(UITapGestureRecognizer *)tgr
{
    NSLog(@"tapped!");
}

-(IBAction)buttonHighlight:(id)sender
{
    UIColor *highlightColor = [UIColor greenColor];
    
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = highlightColor;
    
}

-(IBAction)buttonNormal:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = initialColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeToSaved:NO];
    
    graphButton.backgroundColor = initialColor;
    saveButton.backgroundColor = initialColor;
  
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

-(void)setParameter:(MetasomeParameter *)p
{
    parameter = p;
    //[[self navigationItem] setTitle:[p parameterName]];
    
    UILabel *titleLabelView = [[UILabel alloc] initWithFrame:CGRectZero];
    [TextFormatter formatTitleLabel:titleLabelView withTitle:[p parameterName]];
    [[self navigationItem] setTitleView:titleLabelView];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
    
}

//selector 'savePoint' is called when the 'save'
//button on nav bar is clicked
-(void)savePoint:(id)sender
{
    // make sure entered date is not past today's date
    if ( [[datePicker date] timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970] ) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Future dates are not allowed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    float floatValue = [valueSlider value]*100;
    int intValue = (int)floatValue;
    
    // addPointWithName method in MetasomeDataPointStore returns a pointer to last saved point
    // used for manual undo management
    lastPointSaved = [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:intValue date:datePicker.date.timeIntervalSince1970 options:noOptions fromApi:nil];
    
    BOOL result = [[MetasomeDataPointStore sharedStore] saveChanges];
    [self addUndoButton];
    
    // check to see if the last entry was within past 36 hours; increment if YES,
    // otherwise reset consecutive counter to zero
    if ( [[self parameter] incrementConsecutiveCounter] ) {
        
        [self animateSaveResponse];
    }
    
    // mark parameter as checked
    [[self parameter] setCheckedStatus:YES];
    [[self parameter] setLastChecked:[NSDate date]];
    [[MetasomeParameterStore sharedStore] saveChanges];
    
    
    if (!result) {
        
        NSError *err;
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Write to file failed!" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    }

    
    [self changeToSaved:YES];
    // sent hit data to google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:self.parameter.parameterName          // Event label
                                                           value:nil] build]];    // Event value
    
}

-(IBAction)graphParameter:(id)sender
{
    [[MetasomeDataPointStore sharedStore] setToGraph:[parameter parameterName]];
    
    // Make sure there exists at least one data point before graphing
    // Block 'isDataPointStoreEmpty' is defined in ParameterViewController
    
    if (isDataPointStoreNonEmpty()) {
        GraphViewController *gvc = [[GraphViewController alloc] init];
        [[self navigationController] pushViewController:gvc animated:YES];
        
    }
    
    [graphButton setBackgroundColor:initialColor];

    
}

-(void)sliderValueChanged
{
    [self changeToSaved:NO];
    
    // if this is a custom-made parameter, don't set any images
    if ([[self parameter] isCustomMade])
        return;
    
    // divide slider into pieces
    int position = (int)([valueSlider value]*100) / (100/NUM_SLIDER_SECTIONS);
    
    switch (position) {
        case 0:
            if ([parameter sadOnRightSide])
                [smileyImage setImage:[UIImage imageNamed:@"smiley0.png"]];
            else
                [smileyImage setImage:[UIImage imageNamed:@"smiley4.png"]];
            break;
            
        case 1:
            if ([parameter sadOnRightSide])
                [smileyImage setImage:[UIImage imageNamed:@"smiley1.png"]];
            else
                [smileyImage setImage:[UIImage imageNamed:@"smiley3.png"]];
            break;
        
        case 2:
            [smileyImage setImage:[UIImage imageNamed:@"smiley2.png"]];
            break;
        
        case 3:
            if ([parameter sadOnRightSide])
                [smileyImage setImage:[UIImage imageNamed:@"smiley3.png"]];
            else
                [smileyImage setImage:[UIImage imageNamed:@"smiley1.png"]];
            break;
            
        case 4:
            if ([parameter sadOnRightSide])
                [smileyImage setImage:[UIImage imageNamed:@"smiley4.png"]];
            else
                [smileyImage setImage:[UIImage imageNamed:@"smiley0.png"]];
            break;
            
    }
}

-(void)changeToSaved:(BOOL)savedState
{
    if (savedState == YES ) {
        [saveButton setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.7]];
        [saveButton setTitle:@"Saved!" forState:UIControlStateNormal];
        [[self view] endEditing:YES];

    } else {
        [saveButton setBackgroundColor:initialColor];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    }
    
    [self setIsSaved:savedState];
    
}

-(void)addUndoButton
{
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoSavePoint)];
    
    [[self navigationItem] setRightBarButtonItem:undoButton];
    
}

-(void)undoSavePoint
{
    [[MetasomeDataPointStore sharedStore] removePoint:lastPointSaved];
    [[MetasomeDataPointStore sharedStore] saveChanges];
    
    [[self navigationItem] setRightBarButtonItem:nil];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Undo" message:@"The last data point was successfully removed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    
    // hide gamification text and image; re-display buttons and text field
    saluteImage.hidden = YES;
    saluteLabel.hidden = YES;
    [graphButton setHidden:NO];
    [saveButton setHidden:NO];
    [self changeToSaved:NO];
    valueSlider.hidden = NO;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // after the animation is complete, hide saluteLabel,
    // saluteImage, and re-display the buttons, smiley and slider
    
    saluteLabel.hidden = YES;
    saluteImage.hidden = YES;
    
    [graphButton setHidden:NO];
    [saveButton setHidden:NO];
    valueSlider.hidden = NO;
    smileyImage.hidden = NO;
    datePicker.hidden = NO;
    
    
}


-(void)animateSaveResponse
{
    NSLog(@"consecutiveEntries: %i", [[self parameter] consecutiveEntries]);
    // hide UITextField and buttons
    valueSlider.hidden = YES;
    [graphButton setHidden:YES];
    [saveButton setHidden:YES];
    [smileyImage setHidden:YES];
    [datePicker setHidden:YES];
    
    // make saluteLabel and saluteText visible
    saluteLabel.hidden = NO;
    saluteImage.hidden = NO;
    [saluteImage setImage:[UIImage imageNamed:@"heartButton.png"]];
    
    // fade in saluteLabel and saluteImage
    CAKeyframeAnimation *fade = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    [fade setDelegate:self];
    [fade setDuration:4.0];
    NSMutableArray *vals = [NSMutableArray array];
    [vals addObject:[NSNumber numberWithFloat:0.0]];
    [vals addObject:[NSNumber numberWithFloat:1.0]];
    [vals addObject:[NSNumber numberWithFloat:0.0]];
    [fade setValues:vals];
    
    NSString *firstPart;
    if ([[self parameter] consecutiveEntries] < 2 )
        firstPart = @"";
    else
        firstPart = [NSString stringWithFormat:@"%i days in a row! \n", [[self parameter] consecutiveEntries]];
    
    NSMutableArray *secondParts = [NSMutableArray array];
    [secondParts addObject:@"You've earned an apple! An apple a day keeps the doctor away."];
    [secondParts addObject:@"Another apple. You're on a roll!"];
    [secondParts addObject:@"Keep it up!"];
    [secondParts addObject:@"It'll be a bushel before you know it!"];
    [secondParts addObject:@"Wow, a bushel of apples! You're doing great!"];
    [secondParts addObject:@"Here's a bin to hold all your apples! Your doctor will be proud."];
    [secondParts addObject:@"Great work! You've sown the seeds of an apple tree."];
    [secondParts addObject:@"Your fully grown tree bears the fruit of your effort!"];
    [secondParts addObject:@"You're officially a tracking pro! You've earned the Golden Apple!"];
    
    int numConsecutive = [[self parameter] consecutiveEntries];
    
    if (numConsecutive == 1) {  // first entry
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:0]];
        saluteImage.image = [UIImage imageNamed:@"single_apple"];
    }
    else if (numConsecutive == 2) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:1]];
        saluteImage.image = [UIImage imageNamed:@"double_apple"];
        
    }
    else if (numConsecutive == 3) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:2]];
        saluteImage.image = [UIImage imageNamed:@"triple_apple"];
        
    }
    else if (numConsecutive == 4) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:3]];
        saluteImage.image = [UIImage imageNamed:@"quadruple_apple"];
    }
    else if (numConsecutive >= 5 && numConsecutive <7 ) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:4]];
        saluteImage.image = [UIImage imageNamed:@"apple_bushel"];
        
    }
    else if (numConsecutive >= 7 && numConsecutive < 9) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:5]];
        saluteImage.image = [UIImage imageNamed:@"apple_bin"];
        
    }
    else if (numConsecutive >= 9 && numConsecutive < 11) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:6]];
        saluteImage.image = [UIImage imageNamed:@"simple_tree"];
        
    }
    else if (numConsecutive >= 11 && numConsecutive < 15) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:7]];
        saluteImage.image = [UIImage imageNamed:@"full_apple_tree"];
        
    }
    else if (numConsecutive >= 15 ) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:8]];
        saluteImage.image = [UIImage imageNamed:@"golden_apple"];
        
    }
    
    /*
     else if (numConsecutive >= 21 && numConsecutive < 25) {
     saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:9]];
     saluteImage.image = [UIImage imageNamed:@"single_apple"];
     
     }
     else {
     saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:10]];
     saluteImage.image = [UIImage imageNamed:@"single_apple"];
     }
     */
    
    // associated animation with saluteLabel and saluteImage
    [saluteLabel.layer addAnimation:fade forKey:@"fadeInAnimation"];
    [saluteImage.layer addAnimation:fade forKey:@"fadeInAnimation"];
    
}


@end
