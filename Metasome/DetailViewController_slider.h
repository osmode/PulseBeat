//
//  DetailViewController_slider.h
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MetasomeParameter;

@interface DetailViewController_slider : UIViewController <UITextFieldDelegate>
{
        
    __weak IBOutlet UIButton *saveButton;
    __weak IBOutlet UISlider *valueSlider;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIButton *graphButton;

    UIImage *saveButtonPreChecked, *saveButtonChecked;
    UIColor *initialColor;
    
}


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
