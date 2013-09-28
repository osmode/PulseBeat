//
//  MetasomeBloodPressureViewController.h
//  Metasome
//
//  Created by Omar Metwally on 9/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MetasomeParameter;
@interface MetasomeBloodPressureViewController : UIViewController
{
    
    __weak IBOutlet UITextField *systolicTextField;
    __weak IBOutlet UITextField *diastolicTextField;
    __weak IBOutlet UIButton *saveButton;
    __weak IBOutlet UIButton *graphButton;
    __weak IBOutlet UIDatePicker *datePicker;
    
    UIImage *saveButtonPreChecked, *saveButtonChecked;
    UIColor *initialColor;
    
}

@property (strong, nonatomic) MetasomeParameter *parameter;
@property (nonatomic, copy) BOOL (^isDataPointStoreNonEmpty)(void);
@property (nonatomic) BOOL isSaved;

-(IBAction)graphParameter:(id)sender;
-(IBAction)savePoint:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
-(void)keyboardWillShow;
-(void)changeToSaved:(BOOL)savedState;

@end
