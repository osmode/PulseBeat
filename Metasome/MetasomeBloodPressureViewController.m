//
//  MetasomeBloodPressureViewController.m
//  Metasome
//
//  Created by Omar Metwally on 9/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeBloodPressureViewController.h"
#import "MetasomeParameter.h"
#import "MetasomeDataPointStore.h"
#import "GraphViewController.h"
#import "TextFormatter.h"
#import "MetasomeParameterStore.h"


@interface MetasomeBloodPressureViewController ()

@end

@implementation MetasomeBloodPressureViewController
@synthesize parameter, isDataPointStoreNonEmpty, isSaved;
@synthesize lastPointSavedSystolic, lastPointSavedDiastolic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

            
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
    initialColor = [graphButton backgroundColor];
    saveButton.layer.cornerRadius = 10.0;
    graphButton.layer.cornerRadius = 10.0;
    
    // change background colors when buttons are clicked
    
    [graphButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [graphButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    
    [saveButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [saveButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    
    // create notification to know when text size is changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    systolicTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    diastolicTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    // initially hide the salulateLabel and saluteImage
    saluteImage.hidden = YES;
    saluteLabel.hidden = YES;

}

-(void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    systolicTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    diastolicTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
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

-(IBAction)backgroundTapped:(id)sender
{
    [[self view] endEditing:YES];
}
-(void)savePoint:(id)sender
{
    // make sure entered value is not greater than parameter's max allowed value before saving
    if ( [parameter isWithinMaxValue:[[systolicTextField text] floatValue]] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Systolic value is too large!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        return;
    }
    
    // make sure entered value is not greater than parameter's max allowed value before saving
    if ( [parameter isWithinMaxValue:[[diastolicTextField text] floatValue]] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Diastolic value is too large!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        return;
    }
    
    // make sure a value was entered
    if (systolicTextField.text.length * diastolicTextField.text.length == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Text field(s) is empty!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    // make sure entered date is not past today's datex
    if ( [[datePicker date] timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970] ) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Future dates are not allowed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    lastPointSavedSystolic = [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:systolicTextField.text.integerValue date:datePicker.date.timeIntervalSince1970 options:systolicOptions fromApi:nil];
    
    lastPointSavedDiastolic = [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:diastolicTextField.text.integerValue date:datePicker.date.timeIntervalSince1970 options:diastolicOptions fromApi:nil];
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setIsSaved:NO];
    [self changeToSaved:NO];
    
    // reset background colors
    graphButton.backgroundColor = initialColor;
    saveButton.backgroundColor = initialColor;
    
}

-(void)graphParameter:(id)sender
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [[MetasomeDataPointStore sharedStore] removePoint:lastPointSavedSystolic];
    [[MetasomeDataPointStore sharedStore] removePoint:lastPointSavedDiastolic];
    
    [[MetasomeDataPointStore sharedStore] saveChanges];
    
    [[self navigationItem] setRightBarButtonItem:nil];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // after the animation is complete, hide saluteLabel,
    // saluteImage, and re-display the buttons and text field
    saluteLabel.hidden = YES;
    saluteImage.hidden = YES;
    
    [graphButton setHidden:NO];
    [saveButton setHidden:NO];
    systolicTextField.hidden = NO;
    diastolicTextField.hidden = NO;
    
}

-(void)animateSaveResponse
{
    NSLog(@"consecutiveEntries: %i", [[self parameter] consecutiveEntries]);
    // hide UITextField and buttons
    systolicTextField.hidden = YES;
    diastolicTextField.hidden = YES;
    
    [graphButton setHidden:YES];
    [saveButton setHidden:YES];
    
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
