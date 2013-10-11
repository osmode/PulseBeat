//
//  OptionsViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/23/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OptionsTableView, OAuth1Controller;
@interface OptionsViewController : UITableViewController <UIAlertViewDelegate, UINavigationControllerDelegate>
{

    IBOutlet UITableView *tableView;
    NSString *MetasomeNotificationPrefKey;

}
-(void)resetParameters;
-(void)promptWithString:(NSString *)prompt;

@property (nonatomic, copy) void (^selectedActionBlock)(void);
@property (nonatomic, strong) OAuth1Controller *oauth1Controller;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;

@end
