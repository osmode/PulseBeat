//
//  DetailViewController_slider.h
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class MetasomeParameter, MetasomeDataPoint;

@interface DetailViewController_slider : GAITrackedViewController <UITextFieldDelegate>
{
        
    __weak IBOutlet UIButton *saveButton;
    __weak IBOutlet UISlider *valueSlider;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIButton *graphButton;

    UIImage *saveButtonPreChecked, *saveButtonChecked;
    __weak IBOutlet UIImageView *saluteImage;
    __weak IBOutlet UILabel *saluteLabel;
    
    UIColor *initialColor;
    
}

@property (nonatomic, strong) MetasomeDataPoint *lastPointSaved;
@property (strong, nonatomic) MetasomeParameter *parameter;
@property (nonatomic, copy) BOOL (^isDataPointStoreNonEmpty)(void);
@property (nonatomic) BOOL isSaved;
@property (strong, nonatomic) IBOutlet UIImageView *smileyImage;


-(IBAction)graphParameter:(id)sender;
-(IBAction)savePoint:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
-(void)changeToSaved:(BOOL)savedState;
-(void)sliderValueChanged;

@end
