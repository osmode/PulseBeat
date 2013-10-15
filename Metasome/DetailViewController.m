//
//  DetailViewController.m
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "DetailViewController.h"
#import "MetasomeParameter.h"
#import "MetasomeDataPoint.h"
#import "MetasomeDataPointStore.h"
#import "GraphViewController.h"
#import "ParameterViewController.h"
#import "TextFormatter.h"
#import "MetasomeParameterStore.h"


@implementation DetailViewController
@synthesize parameter, isDataPointStoreNonEmpty, isSaved, lastPointSaved;

-(id)init
{
    self = [super init];

    [valueField setDelegate:self];
    return self;
    
    //lastPointSaved = [[MetasomeDataPoint alloc] init];
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[self parameter] inputType] == ParameterInputInteger)
        valueField.keyboardType = UIKeyboardTypeNumberPad;
    
    // if recording sleep hours, we only want a time picker
    if ([[[self parameter] parameterName] isEqualToString:@"Sleep hours"]) {
        
        [datePicker setDatePickerMode:UIDatePickerModeDate];
    
    }
    
    valueField.delegate = self;
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
    // add units if this is the weight parameter
    if ([[[self parameter] parameterName] isEqualToString:@"Weight"]) {
        valueField.placeholder = @"Enter lbs";
    }
    
    initialColor = [[self saveButton] backgroundColor];
    _saveButton.layer.cornerRadius = 10.0;
    _graphButton.layer.cornerRadius = 10.0;
    
    _saveButton.layer.drawsAsynchronously = YES;
    _graphButton.layer.drawsAsynchronously = YES;
    
    // change background colors when buttons are clicked
    
    [[self graphButton] addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [[self graphButton] addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    
    [[self saveButton] addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [[self saveButton] addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    
    // create notification to know when text size is changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    // initially hide saluteLabel and saluteImage
    saluteLabel.hidden = YES;
    saluteImage.hidden = YES;
    
}

-(void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    valueField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    valueField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    [[self view] setNeedsLayout];
    
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

-(void)keyboardWillShow
{
    [self changeToSaved:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setIsSaved:NO];
    [self changeToSaved:NO];
    
    // reset button colors
    self.graphButton.backgroundColor = initialColor;
    self.saveButton.backgroundColor = initialColor;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)setParameter:(MetasomeParameter *)p
{
    parameter = p;
    //[[self navigationItem] setTitle:[p parameterName]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [TextFormatter formatTitleLabel:titleLabel withTitle:[p parameterName]];
    [[self navigationItem] setTitleView:titleLabel];
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
    
    // make sure entered value is not greater than parameter's max allowed value before saving
    if ( [parameter isWithinMaxValue:[[valueField text] floatValue]] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Entered value is too large!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        return;
    }
    
    // make sure a value was entered
    if (valueField.text.length == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Text field(s) is empty!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    // make sure entered date is not past today's date
    if ( [[datePicker date] timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970] ) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Future dates are not allowed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    //create new data point object
    //and save it to data point store
    //actual write to disk occurs on
    //applicationDidEnterBackground
    
    int intToSave = 0;
    float floatToSave = 0.0;
    
    if ([[self parameter] inputType] == ParameterInputFloat) {
        floatToSave = [[valueField text] floatValue];
        lastPointSaved = [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:floatToSave date:datePicker.date.timeIntervalSince1970 options:noOptions];
        
    } else {
        intToSave = [[valueField text] integerValue];
        lastPointSaved = [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:intToSave date:datePicker.date.timeIntervalSince1970 options:noOptions];
    }
    
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
    
    //[[self navigationController]popViewControllerAnimated:YES];
    [self changeToSaved:YES];
    
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
    
    [[self graphButton] setBackgroundColor:initialColor];


}

-(void)changeToSaved:(BOOL)savedState
{
    if (savedState == YES ) {
        [[self saveButton] setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.7]];
        [[self saveButton] setTitle:@"Saved!" forState:UIControlStateNormal];
        [[self view] endEditing:YES];
        
    } else {
        [[self saveButton] setBackgroundColor:initialColor];
        [[self saveButton] setTitle:@"Save" forState:UIControlStateNormal];
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
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // after the animation is complete, hide saluteLabel,
    // saluteImage, and re-display the buttons and text field
    saluteLabel.hidden = YES;
    saluteImage.hidden = YES;
    
    [[self graphButton] setHidden:NO];
    [[self saveButton] setHidden:NO];
    valueField.hidden = NO;
    
    
}
-(void)animateSaveResponse
{
    NSLog(@"consecutiveEntries: %i", [[self parameter] consecutiveEntries]);
    // hide UITextField and buttons
    valueField.hidden = YES;
    [[self graphButton] setHidden:YES];
    [[self saveButton] setHidden:YES];
    
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
    [secondParts addObject:@"An apple a day keeps the doctor away!"];
    [secondParts addObject:@"You're on a roll!"];
    [secondParts addObject:@"Keep it up!"];
    [secondParts addObject:@"Tracking your health helps you take charge of your medical decisions!"];
    [secondParts addObject:@"You're on fire!"];
    [secondParts addObject:@"Your doctor will be proud!"];
    [secondParts addObject:@"Awesome!!!"];
    [secondParts addObject:@"You're a lean, mean, health tracking machine!"];
    [secondParts addObject:@"Drum roll please..."];
    [secondParts addObject:@"I wish all patients could be like you..."];
    [secondParts addObject:@"You've come too far to break this hot streak!"];
    //[secondParts addObject:nil];
    
    int numConsecutive = [[self parameter] consecutiveEntries];
    
    if (numConsecutive == 1)
        firstPart = @"";
    
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
