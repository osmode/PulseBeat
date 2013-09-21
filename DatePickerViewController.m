//
//  DatePickerViewController.m
//  Metasome
//
//  Created by Omar Metwally on 9/5/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()

@end

@implementation DatePickerViewController

-(id)init
{    
    self = [super init];
    if (self) {

    }
    return self;
}

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
    
    // If an event (and corresponding date) already exist, initialize the UIDatePicker
    if ( [[self parentDateController] eventSelected] ) {
        [[self datePicker] setDate:[[[self parentDateController] eventSelected] date]];
    }
    
    /*
    UIImage *buttonImage = [UIImage imageNamed:@"cancel.png"];
    UIButton *button = [UIButton buttonWithTyp
     e:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTitle:@"blah" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 60, 20);
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [customBarItem setTitle:@"TITLE!"];
    self.navigationItem.leftBarButtonItem = customBarItem;
     */
    
    
}
-(void)goBack
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelSelected:(id)sender {
    
    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (IBAction)okSelected:(id)sender {
    self.navigationController.navigationBar.hidden = NO;

    // nevc points to NewEventViewController
    [[[self parentDateController] eventSelected] setDate:[[self datePicker] date] ];
    NSLog(@"event selected date set to: %@", self.parentDateController.eventSelected.date);
    
    [[[self parentDateController] view] setNeedsDisplay];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm"];
    self.parentDateController.dateSelected = [[self datePicker] date];
    [[[self parentDateController] dateLabel] setText:[dateFormatter stringFromDate:self.parentDateController.dateSelected]];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(okSelected:)];
    UIBarButtonItem *cancelButon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelected:)];
    
    [[self navigationItem] setRightBarButtonItem:saveButton];
    [[self navigationItem] setLeftBarButtonItem:cancelButon];
    [[self navigationItem] setTitle:@"Select new date"];
}


-(void)newEventViewController:(NewEventViewController *)nevc handleObject:(id)object
{

    
}
@end
