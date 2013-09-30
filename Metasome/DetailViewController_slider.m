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
    
    lastPointSaved = [[MetasomeDataPointStore sharedStore] addPointWithName:[parameter parameterName] value:[valueSlider value]*100 date:datePicker.date.timeIntervalSince1970 options:noOptions];
    
    BOOL result = [[MetasomeDataPointStore sharedStore] saveChanges];
    [self addUndoButton];
    
    // mark parameter as checked
    [[self parameter] setCheckedStatus:YES];
    [[self parameter] setLastChecked:[NSDate date]];
    [[MetasomeParameterStore sharedStore] saveChanges];
    
    
    if (!result) {
        
        NSError *err;
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Write to file failed!" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    }
    
    // make sure entered date is not past today's date
    if ( [[datePicker date] timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970] ) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Future dates are not allowed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
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
    
    // divide slider into pieces
    int position = (int)([valueSlider value]*100) / (100/NUM_SLIDER_SECTIONS);
    
    if ([parameter sadOnRightSide])
        NSLog(@"sadOnRightSide");
    else
        NSLog(@"sadOnLeftSide");
    
    
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



@end
