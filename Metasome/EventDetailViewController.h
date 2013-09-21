//
//  EventDetailViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/26/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailViewController : UIViewController <UITextFieldDelegate>

-(BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)backgroundTouched:(id)sender;

@end
