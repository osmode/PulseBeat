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
    lastPointSaved = [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:intValue date:datePicker.date.timeIntervalSince1970 options:noOptions];
    
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
    //[[self navigationController]popViewControllerAnimated:YES];
 
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
    
}

-(void)animateSaveResponse
{
    NSLog(@"consecutiveEntries: %i", [[self parameter] consecutiveEntries]);
    
    // hide slide, smiley, and buttons
    valueSlider.hidden = YES;
    [graphButton setHidden:YES];
    [saveButton setHidden:YES];
    [smileyImage setHidden:YES];
    
    // make saluteLabel and saluteText visible
    saluteLabel.hidden = NO;
    saluteImage.hidden = NO;
    [saluteImage setImage:[UIImage imageNamed:@"heartButton.png"]];
    
    // fade in saluteLabel and saluteImage
    
    CAKeyframeAnimation *fade = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    [fade setDelegate:self];
    [fade setDuration:2.5];
    NSMutableArray *vals = [NSMutableArray array];
    [vals addObject:[NSNumber numberWithFloat:0.0]];
    [vals addObject:[NSNumber numberWithFloat:1.0]];
    [vals addObject:[NSNumber numberWithFloat:0.0]];
    [fade setValues:vals];
    
    NSString *firstPart = [NSString stringWithFormat:@"%i days in a row! \n", [[self parameter] consecutiveEntries]];
    NSMutableArray *secondParts = [NSMutableArray array];
    [secondParts addObject:@"You're on a roll!"];
    [secondParts addObject:@"Keep it up!"];
    [secondParts addObject:@"Tracking your health helps you take charge of your medical decisions."];
    [secondParts addObject:@"Prevention is the best medicine!"];
    [secondParts addObject:@"You're on fire!"];
    [secondParts addObject:@"Your doctor will be proud!"];
    [secondParts addObject:@"Awesome!!!"];
    [secondParts addObject:@"You're a lean, mean, health tracking machine!"];
    [secondParts addObject:@"Drum roll please..."];
    [secondParts addObject:@"I wish all patients could be like you..."];
    [secondParts addObject:@"You've come too far to break this hot streak!"];
    //[secondParts addObject:nil];
    
    int numConsecutive = [[self parameter] consecutiveEntries];
    
    if (numConsecutive == 0) return;
    else if (numConsecutive == 1) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:0]];
    }
    else if (numConsecutive == 2) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:1]];
    }
    else if (numConsecutive == 3) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:2]];
    }
    else if (numConsecutive >= 4 && numConsecutive <6 ) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:3]];
    }
    else if (numConsecutive >= 6 && numConsecutive < 8) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:4]];
    }
    else if (numConsecutive >= 8 && numConsecutive < 10) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:5]];
    }
    else if (numConsecutive >= 11 && numConsecutive < 14) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:6]];
    }
    else if (numConsecutive >= 14 && numConsecutive < 17) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:7]];
    }
    else if (numConsecutive >= 17 && numConsecutive < 21) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:8]];
    }
    else if (numConsecutive >= 21 && numConsecutive < 25) {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:9]];
    }
    else {
        saluteLabel.text = [firstPart stringByAppendingString:[secondParts objectAtIndex:10]];
        
    }
    
    
    // associated animation with saluteLabel and saluteImage
    [saluteLabel.layer addAnimation:fade forKey:@"fadeInAnimation"];
    [saluteImage.layer addAnimation:fade forKey:@"fadeInAnimation"];
    
}



@end
