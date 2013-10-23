//
//  NewParameterViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/30/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface NewParameterViewController : GAITrackedViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    NSArray *categoryChoices;
    NSArray *inputChoices;
    IBOutlet UITextField *newParameterName;
    
    __weak IBOutlet UILabel *categoryLabe;
    __weak IBOutlet UILabel *inputLabel;
    __weak IBOutlet UIButton *categoryButton;
    __weak IBOutlet UIButton *inputButton;
    
    UIColor *initialColor;
}

- (IBAction)changeCategory:(id)sender;
- (IBAction)changeInput:(id)sender;

@property (strong, nonatomic) IBOutlet UIPickerView *parameterCategory;

@property (strong, nonatomic) IBOutlet UIPickerView *parameterInput;

-(void)saveParameter;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)backgroundTouched:(id)sender;
-(void)flipButton:(UIButton *)buttonToSelect;

@end
