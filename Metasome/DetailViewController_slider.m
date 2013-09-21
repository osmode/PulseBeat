//
//  DetailViewController.m
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

@implementation DetailViewController_slider
@synthesize parameter, isDataPointStoreNonEmpty;

-(id)init
{
    self = [super init];
    //UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePoint:)];
    
    //[[self navigationItem] setRightBarButtonItem:saveButton];
    
    saveButtonChecked = [UIImage imageNamed:@"checkedButton.png"];
    saveButtonPreChecked = [UIImage imageNamed:@"saveButton.png"];
    
    return self;
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *clr = [UIColor colorWithRed:0.875 green:0.88 blue:0.91 alpha:1];
    
    [[self view] setBackgroundColor:clr];
    [valueSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventTouchDown];

}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeToSaved:NO];
  
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
    //create new data point object
    //and save it to data point store
    //actual write to disk occurs on
    //applicationDidEnterBackground
    
    [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:[valueSlider value]*100 date:datePicker.date.timeIntervalSince1970];
    
    BOOL result = [[MetasomeDataPointStore sharedStore] saveChanges];
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
    
}

-(void)sliderValueChanged
{
    [self changeToSaved:NO];
}

-(void)changeToSaved:(BOOL)savedState
{
    if (savedState == YES ) {
        //[[self saveButton] setBackgroundImage:[UIImage imageNamed:@"fuzzyGreenButtonNoGlow.png"] forState:UIControlStateNormal];
        [saveButton setBackgroundImage:saveButtonChecked forState:UIControlStateNormal];
        [saveButton setTitle:@"" forState:UIControlStateNormal];
    } else {
        //[[self saveButton] setBackgroundImage:[UIImage imageNamed:@"fuzzyRedButtonNoGlow"] forState:UIControlStateNormal];
        [saveButton setBackgroundImage:saveButtonPreChecked forState:UIControlStateNormal];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    }
    
    [self setIsSaved:savedState];
    
}

@end
