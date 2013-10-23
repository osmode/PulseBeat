//
//  NotificationsDetailViewController.m
//  Metasome
//
//  Created by Omar Metwally on 9/15/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "NotificationsDetailViewController.h"
#import "TextFormatter.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface NotificationsDetailViewController ()

@end

NSString * const MetasomeNotificationPrefKey = @"MetasomeNotificationPrefKey";

@implementation NotificationsDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [TextFormatter formatTitleLabel:titleLabel withTitle:@"Reminders"];
        [[self navigationItem] setTitleView:titleLabel];
        
    }
    return self;
}

-(void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    [promptLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [promptLabel2 setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];

    [self.view setNeedsLayout];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up google analytics view
    [self setScreenName:@"NotificationsDetailViewController"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
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

    UISwitch *s = (UISwitch *)sender;
    
    [[NSUserDefaults standardUserDefaults] setBool:s.on forKey:MetasomeNotificationPrefKey];

}

/* save local notification only when going backward to previous screen */
-(void)viewWillDisappear:(BOOL)animated
{
    
    if (!notificationSwitch.on)
        return;
    
    // Start by clearing all notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    // set fire date to current date at the selected time on UIDatePicker
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [calendar components:(NSHourCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    
    NSDateComponents *pickerComponents = [[NSDateComponents alloc] init];
    pickerComponents = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[timePicker date]];
    
    [components setHour:pickerComponents.hour];
    [components setMinute:pickerComponents.minute];
    [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
    
    NSDate *dateToFire = [calendar dateFromComponents:components];
    
    localNotification.fireDate = dateToFire;
    localNotification.alertBody = @"Remember to log your PulseBeat data!";
    localNotification.alertAction = @"OK";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    localNotification.applicationIconBadgeNumber = 1;
    [localNotification setRepeatInterval:NSDayCalendarUnit ];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    
    // send hit data to google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"button_press" label:@"notifications set ON" value:nil] build]];
    
}

@end
