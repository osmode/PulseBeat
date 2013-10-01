//
//  NewParameterViewController.m
//  Metasome
//
//  Created by Omar Metwally on 8/30/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "NewParameterViewController.h"
#import "MetasomeParameterStore.h"
#import "MetasomeParameter.h"
#import "TextFormatter.h"

@implementation NewParameterViewController
@synthesize parameterCategory, parameterInput;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"New Parameter";
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveParameter)];
        
        [[self navigationItem] setRightBarButtonItem:saveButton];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [TextFormatter formatTitleLabel:titleLabel withTitle:@"New Parameter"];
        [[self navigationItem] setTitleView:titleLabel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The order of these two arrays is important and must correspond to the enumerated types in
    // "MetasomeParameter.h"
    categoryChoices = [[NSArray alloc] initWithArray:[[MetasomeParameterStore sharedStore] sections]];
    inputChoices = [[NSArray alloc] initWithObjects:@"Slider bar", @"Text field (no decimals)", @"Text field (allow decimals)",  nil];
    
    [categoryButton setHighlighted:YES];
    //[[self parameterCategory] setHidden:YES];
    [[self parameterInput] setHidden:YES];
    
    inputButton.layer.cornerRadius = 5.0;
    categoryButton.layer.cornerRadius = 5.0;
    
}
-(IBAction)changeCategory:(id)sender
{
    [self performSelector:@selector(flipButton:) withObject:categoryButton afterDelay:0.0];

    [parameterCategory setHidden:NO];
    [parameterInput setHidden:YES];
     
}
-(IBAction)changeInput:(id)sender
{
    [self performSelector:@selector(flipButton:) withObject:inputButton afterDelay:0.0];
    
    [parameterInput setHidden:NO];
    [parameterCategory setHidden:YES];
    
}

-(void)flipButton:(UIButton *)buttonToSelect
{
    categoryButton.highlighted = NO;
    inputButton.highlighted = NO;
    
    buttonToSelect.highlighted = YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTouched:(id)sender {
    [[self view] endEditing:YES];
    NSLog(@"Background touched.");
}

-(void)saveParameter
{
    if ([[newParameterName text] length] == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a title for the new parameter!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    NSString *newName = [newParameterName text];
    NSInteger input = [[self parameterInput] selectedRowInComponent:0];
    NSInteger category = [[self parameterCategory] selectedRowInComponent:0];
    
    MetasomeParameter *newParameter = [[MetasomeParameter alloc] initWithParameterName:newName inputType:input category:category maximumValue:100.0];
    [newParameter setIsCustomMade:YES];
    
    if (input != ParameterInputSlider)
        [newParameter setMaxValue:1000];
    
    [[MetasomeParameterStore sharedStore] addParameter:newParameter];
    
    [[MetasomeParameterStore sharedStore] saveChanges];
    
    NSLog(@"newParameter added: %i", newParameter.inputCategory);
    
    [[self navigationController] popViewControllerAnimated:YES];
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"Calling numberOfRowsInComponent");
    NSLog(@"pickView tag: %i", pickerView.tag);
    
    //category (e.g. vital signs, mind, body, etc)
    
    if (pickerView.tag ==0 ) {
        return [[[MetasomeParameterStore sharedStore] sections] count];
    }
    
    //Input type
    else if (pickerView.tag == 1) {
        return [inputChoices count];
    }
   else
        return 0;
    
    return 1;
    NSLog(@"End numberOfRowsInComponent");
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{

    //category (e.g. vital signs, mind, body)
    
    if ([pickerView tag] == 0) {
        return [categoryChoices objectAtIndex:row];
    }
    else if ([pickerView tag] == 1) {
        return [inputChoices objectAtIndex:row];
    }
    else
        return nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
