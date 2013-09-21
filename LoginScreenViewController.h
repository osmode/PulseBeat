//
//  LoginScreenViewController.h
//  Metasome
//
//  Created by Omar Metwally on 9/17/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginScreenViewController : UIViewController <UITableViewDelegate>
{
    
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UIButton *cancelButton;
    
    __weak IBOutlet UIButton *saveEmailButton;
}

- (IBAction)saveEmail:(id)sender;
- (IBAction)cancelSelected:(id)sender;
- (IBAction)backgroundTouched:(id)sender;

@end
