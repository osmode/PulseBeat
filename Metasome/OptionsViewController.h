//
//  OptionsViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/23/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OptionsTableView;
@interface OptionsViewController : UITableViewController <UIAlertViewDelegate>
{

    IBOutlet UITableView *tableView;
    
}
-(void)resetParameters;
-(void)promptWithString:(NSString *)prompt;

@property (nonatomic, copy) void (^selectedActionBlock)(void);

@end
