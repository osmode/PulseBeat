//
//  NotificationsDetailViewController.h
//  Metasome
//
//  Created by Omar Metwally on 9/15/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface NotificationsDetailViewController : GAITrackedViewController
{
    __weak IBOutlet UILabel *promptLabel;
    __weak IBOutlet UISwitch *notificationSwitch;
    __weak IBOutlet UIDatePicker *timePicker;
    __weak IBOutlet UILabel *promptLabel2;
    
}

-(void)switchChanged:(id)sender;

@end
