//
//  DatePickerViewController.h
//  Metasome
//
//  Created by Omar Metwally on 9/5/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewEventViewController.h"

@interface DatePickerViewController : UIViewController <NewEventViewControllerDelegate>
{
    
}

// 'parent' points to NewEventViewController
@property (nonatomic, weak) NewEventViewController *parentDateController;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;


- (IBAction)cancelSelected:(id)sender;
- (IBAction)okSelected:(id)sender;


@end
