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
@synthesize parameter, isDataPointStoreNonEmpty, isSaved;

-(id)init
{
    self = [super init];
    //UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePoint:)];
    
    //[[self navigationItem] setRightBarButtonItem:button];

    //saveButtonPreChecked = [[UIImage alloc] initWithContentsOfFile:@"fuzzyRedButtonNoGlow.png"];
    //saveButtonPreChecked = [[UIImage alloc] initWithContentsOfFile:@"fuzzyGreenButtonNoGlow.png"];
    
    saveButtonChecked = [UIImage imageNamed:@"checkedButton.png"];
    saveButtonPreChecked = [UIImage imageNamed:@"saveButton.png"];
    
    [valueField setDelegate:self];
    return self;
    
}

-(void)viewDidLoad
{
    
    [super viewDidLoad];
    if ([[self parameter] inputType] == ParameterInputInteger)
        valueField.keyboardType = UIKeyboardTypeNumberPad;
    
    valueField.delegate = self;
    
    UIColor *clr = [UIColor colorWithRed:0.875 green:0.88 blue:0.91 alpha:1];
    [[self view] setBackgroundColor:clr];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
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
    
    NSLog(@"entered value: %f, max value: %f", [[valueField text] floatValue], [[self parameter] maxValue]);
    
    // make sure entered value is not greater than parameter's max allowed value before saving
    if ( [parameter isWithinMaxValue:[[valueField text] floatValue]] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Entered value is too large!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
        [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:floatToSave date:datePicker.date.timeIntervalSince1970 ];
        
    } else {
        intToSave = [[valueField text] integerValue];
        [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:intToSave date:datePicker.date.timeIntervalSince1970 ];
    }
    
    
    BOOL result = [[MetasomeDataPointStore sharedStore] saveChanges];
    
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

}

-(void)changeToSaved:(BOOL)savedState
{
    if (savedState == YES ) {
        //[[self saveButton] setBackgroundImage:[UIImage imageNamed:@"fuzzyGreenButtonNoGlow.png"] forState:UIControlStateNormal];
        [[self saveButton] setBackgroundImage:saveButtonChecked forState:UIControlStateNormal];
        [[self saveButton] setTitle:@"" forState:UIControlStateNormal];
    } else {
        //[[self saveButton] setBackgroundImage:[UIImage imageNamed:@"fuzzyRedButtonNoGlow"] forState:UIControlStateNormal];
        [[self saveButton] setBackgroundImage:saveButtonPreChecked forState:UIControlStateNormal];
        [[self saveButton] setTitle:@"Save" forState:UIControlStateNormal];
    }
    
    [self setIsSaved:savedState];

}


@end
