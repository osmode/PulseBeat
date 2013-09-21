//
//  NotificationsDetailViewController.m
//  Metasome
//
//  Created by Omar Metwally on 9/15/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "NotificationsDetailViewController.h"

@interface NotificationsDetailViewController ()

@end

NSString * const MetasomeNotificationPrefKey = @"MetasomeNotificationPrefKey";

@implementation NotificationsDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self navigationItem] setTitle:@"Notifications"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [notificationSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    BOOL onState = [[NSUserDefaults standardUserDefaults] boolForKey:MetasomeNotificationPrefKey];
    [notificationSwitch setOn:onState];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)switchChanged:(id)sender
{
    // Start by clearing all notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UISwitch *s = (UISwitch *)sender;
    
    [[NSUserDefaults standardUserDefaults] setBool:s.on forKey:MetasomeNotificationPrefKey];
    
    if (s.on) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components = [calendar components:(NSHourCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
        
        NSDateComponents *pickerComponents = [[NSDateComponents alloc] init];
        components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[timePicker date]];
        
        [components setHour:pickerComponents.hour];
        [components setMinute:pickerComponents.minute];
        [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
        
        NSDate *dateToFire = [calendar dateFromComponents:components];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = dateToFire;
        localNotification.alertBody = @"Remember to log your PulseBeat data!";
        localNotification.alertAction = @"OK";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        localNotification.applicationIconBadgeNumber = 1;
        [localNotification setRepeatInterval:kCFCalendarUnitHour];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
    }
}

@end
