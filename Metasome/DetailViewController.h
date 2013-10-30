//
//  DetailViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
@class MetasomeParameter, MetasomeDataPoint;

@interface DetailViewController : GAITrackedViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>
{
        
    __weak IBOutlet UITextField *valueField;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UILabel *saluteLabel;
    __weak IBOutlet UIImageView *saluteImage;
    
    
    UIImage *saveButtonPreChecked, *saveButtonChecked;
    UIColor *initialColor;
    
}


@property (strong, nonatomic) MetasomeParameter *parameter;
@property (strong, nonatomic) MetasomeDataPoint *lastPointSaved;
@property (nonatomic, copy) BOOL (^isDataPointStoreNonEmpty)(void);
@property (nonatomic) BOOL isSaved;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *graphButton;

-(IBAction)graphParameter:(id)sender;
-(IBAction)savePoint:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
-(void)keyboardWillShow;
-(void)changeToSaved:(BOOL)savedState;
-(void)tapped:(UIGestureRecognizer *)gr;


@end
