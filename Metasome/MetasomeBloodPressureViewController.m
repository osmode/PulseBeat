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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       // UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePoint:)];
        
        //[[self navigationItem] setRightBarButtonItem:button];
        
        //saveButtonPreChecked = [UIImage imageNamed:@"saveButton.png"];
        //saveButtonChecked = [UIImage imageNamed:@"checkedButton.png"];
            
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
    
    [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:systolicTextField.text.integerValue date:datePicker.date.timeIntervalSince1970 options:systolicOptions];
    
    [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:diastolicTextField.text.integerValue date:datePicker.date.timeIntervalSince1970 options:diastolicOptions];
    
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

@end
