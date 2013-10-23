//
//  PrivacyViewController.h
//  PulseBeat
//
//  Created by Omar Metwally on 10/23/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyViewController : UIViewController
{
    
    __weak IBOutlet UILabel *promptLabel;
    __weak IBOutlet UILabel *backgroundLabel;
    __weak IBOutlet UILabel *secondPromptLabel;
    __weak IBOutlet UISwitch *sendSwitch;
}
@end
