//
//  NewEventViewController.m
//  Metasome
//
//  Created by Omar Metwally on 8/26/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "NewEventViewController.h"
#import "MetasomeEventStore.h"
#import "MetasomeEvent.h"
#import "DatePickerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TextFormatter.h"

@implementation NewEventViewController

@synthesize titleTextField, descriptionTextView, visibilitySwitch, dateLabel, dateButton, visibilityLabel, descriptionLabel, dateSelected;
@synthesize titleLabel;
@synthesize originalPoint, toPoint;
@synthesize initialColor;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = @"New Event";
        [self setEventSelected:nil];
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveEvent)];
        
        [[self navigationItem] setRightBarButtonItem:saveButton];
        hintText = @"";
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [TextFormatter formatTitleLabel:titleLabel withTitle:@"New Diary Entry"];
        [[self navigationItem] setTitleView:titleLabel];

    }
    return self;
}

-(void)enterTextView:(NSNotification *)note
{
    
    
}


-(void)exitTextView:(NSNotification *)note
{
    /*
    if ( [[[self descriptionTextView] text] isEqualToString:@""] ) {
        self.descriptionTextView.textColor = [UIColor grayColor];
        [[self descriptionTextView] setText:hintText];
        
    }
    
    CABasicAnimation *down = [CABasicAnimation animationWithKeyPath:@"position"];
    CAMediaTimingFunction *tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [down setFromValue:[NSValue valueWithCGPoint:self.toPoint]];
    //update self.toPoint *after* setting fromValue
    [self setToPoint:self.originalPoint];
    
    [down setToValue:[NSValue valueWithCGPoint:self.originalPoint]];
    [down setDuration:0.25];
    [down setDelegate:self];
    [down setTimingFunction:tf];
    
    [[[self view] layer] addAnimation:down forKey:@"moveDown"];
    
    self.view.center = self.originalPoint;
    */
}

- (IBAction)changeDate:(id)sender {
    
   // [[self navigationController] navigationBar].hidden = YES;
    //self.navigationController.navigationBar.backgroundColor = [UIColor darkGrayColor];
    
    DatePickerViewController *dpvc = [[DatePickerViewController alloc] init];
    [dpvc setParentDateController:self];
    
    [[self navigationController] pushViewController:dpvc animated:YES];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //self.view.center = self.toPoint;
}

-(void)slideViewUp
{
}
-(void)switchChanged:(id)sender
{
    [[self eventSelected] setVisible:self.visibilitySwitch.on];
    [[MetasomeEventStore sharedStore] saveChanges];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTouched:(id)sender {
    [[self view] endEditing:YES];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //IF the table view is asking to commit a delete command
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MetasomeEventStore *es = [MetasomeEventStore sharedStore];
        NSArray *events = [es allEvents];
        MetasomeEvent *event = [events objectAtIndex:[indexPath row]];
        [es removeEvent:event];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(void)saveEvent
{
    
    //Make sure a title has been entered before saving
    if ([[[self titleTextField] text] length] > 0) {
        
        //If opening a pre-existing event record, overwrite
        //that record with the text field/view's contents
        //[self eventSelected] points to an event in the sharedStore
        if ([self eventSelected]) {
            
            [[self eventSelected] setTitle:[[self titleTextField] text]];
            
            if ([[[self descriptionTextView] text] length] == 0)
                [[self eventSelected] setDetails:nil];
            else
                [[self eventSelected] setDetails:[[self descriptionTextView] text]];
            
            [[self eventSelected] setDate:self.dateSelected];
            [[self eventSelected] setVisible:visibilitySwitch.on];
            
        }
        //Otherwise, create a new event and save it in the sharedStore
        else {            
            
            MetasomeEvent *newEvent = [[MetasomeEvent alloc] initWithEventTitle:[[self titleTextField] text] details:[[self descriptionTextView] text] date:self.dateSelected];
            [[MetasomeEventStore sharedStore] addEvent:newEvent];
        }
        
        if (![[MetasomeEventStore sharedStore] saveChanges]) {
            NSLog(@"Unable to save event!");
        }
        
        [[self navigationController] popViewControllerAnimated:YES];

    }
    //If no title is specified, show an alert
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter an event title" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
        [alert show];
    }

}

-(void)preferredContentSizeChanged:(NSNotification *)aNotification {
    
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    titleTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    descriptionTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    dateButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    dateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    visibilityLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    
    [self.view setNeedsLayout];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    initialColor = [[self dateButton] backgroundColor];
    dateButton.layer.cornerRadius = 10.0;
    [dateButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [dateButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    [dateButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [[self visibilitySwitch] addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"dd MMM yyyy HH:mm"];
    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    
    if ([[self eventSelected] date]) {
        dateSelected = self.eventSelected.date;
        self.dateLabel.text = [dateFormatter stringFromDate:[[self eventSelected] date]];
    } else {
        dateSelected = [NSDate date];
        self.dateLabel.text = [dateFormatter stringFromDate:dateSelected];
    }
    
    self.dateLabel.textColor = [UIColor blueColor];
    [dateButton sizeToFit];
    
    //If eventSelected is set to point to a pre-existing event in MetasomeEventStore,
    //populate text field/view and date picker
    if ([self eventSelected]) {
        
        self.titleTextField.text = [[self eventSelected] title];
        self.descriptionTextView.text = [[self eventSelected] details];
        //self.eventDatePicker.date = [[self eventSelected] date];        
        [visibilitySwitch setOn:[[self eventSelected] visible]];
        
    }
    /*
    if ([[self eventSelected] details]) {
        self.descriptionTextView.textColor = [UIColor blackColor];
        [[self descriptionTextView] setText:[[self eventSelected] details]];
    } else {
        self.descriptionTextView.textColor = [UIColor grayColor];
        [[self descriptionTextView] setText:hintText];
    }
    */
        
    // Make the description UITextView look nice
    [self formatTextView:descriptionTextView];
    [self formatLabel:descriptionLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)formatTextView:(UITextView *)tv
{
    //To make the border look very close to a UITextField
    
    [tv.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [tv.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    tv.layer.cornerRadius = 5;
    tv.clipsToBounds = YES;
    
    //[tv setTextContainerInset:UIEdgeInsetsMake(-60.0, 0.0, 0.0, 0.0)];
    //[tv setTextColor:[UIColor blackColor]];
    
}

-(void)formatLabel:(UILabel *)label
{
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [dateButton setBackgroundColor:initialColor];
}

@end
