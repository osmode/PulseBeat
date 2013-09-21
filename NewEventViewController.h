//
//  NewEventViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/26/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MetasomeEvent.h"

@interface NewEventViewController : UIViewController <UITextFieldDelegate>
{
    NSString *hintText;
    int offset;
}

-(void)saveEvent;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;

- (IBAction)backgroundTouched:(id)sender;
-(void)switchChanged:(id)sender;
-(void)enterTextView:(NSNotification *)note;
-(void)exitTextView:(NSNotification *)note;

- (IBAction)changeDate:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UISwitch *visibilitySwitch;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSDate *dateSelected;

@property (nonatomic) CGPoint originalPoint, toPoint;
@property (nonatomic, strong) NSMutableString *oldText;

@property (nonatomic, strong) MetasomeEvent *eventSelected;

@end

// New protocol 'NewEventViewControllerDelegate' to return date from date picker
@protocol NewEventViewControllerDelegate <NSObject>

-(void)newEventViewController:(NewEventViewController *)nevc handleObject:(id)object;
-(void)formatTextView:(UITextView *)tv;
-(void)formatLabel:(UILabel *)label;


@end
