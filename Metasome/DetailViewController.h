//
//  DetailViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MetasomeParameter;

@interface DetailViewController : UIViewController <UITextFieldDelegate>
{
        
    __weak IBOutlet UITextField *valueField;
    __weak IBOutlet UIDatePicker *datePicker;
    
    UIImage *saveButtonPreChecked, *saveButtonChecked;
    UIColor *initialColor;
    
}


@property (strong, nonatomic) MetasomeParameter *parameter;
@property (nonatomic, copy) BOOL (^isDataPointStoreNonEmpty)(void);
@property (nonatomic) BOOL isSaved;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *graphButton;

-(IBAction)graphParameter:(id)sender;
-(IBAction)savePoint:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
-(void)keyboardWillShow;
-(void)changeToSaved:(BOOL)savedState;

@end
