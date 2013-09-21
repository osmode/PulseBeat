//
//  OptionsSwitchCell.h
//  Metasome
//
//  Created by Omar Metwally on 9/15/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionsSwitchCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UIImageView *bellImage;

@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;

@end
