//
//  HomeViewController.m
//  Metasome
//
//  Created by Omar Metwally on 9/13/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "HomeViewController.h"
#import "MetasomeParameterStore.h"
#import "TextFormatter.h"
#import "ParameterViewController.h"
#import "DeviceController.h"
#import "GAITrackedViewController.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "NotificationsDetailViewController.h"


@implementation HomeViewController
@synthesize paramViewController, reminderButton, bellImageView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [TextFormatter formatTitleLabel:titleLabel withTitle:@"PulseBeat"];
        [[self navigationItem] setTitleView:titleLabel];
        
        MetasomeNotificationPrefKey = @"MetasomeNotificationPrefKey";
    
    }
    return self;
}

-(IBAction)buttonHighlight:(id)sender
{
    UIColor *highlightColor = [UIColor greenColor];
  
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = highlightColor;
    
}

-(IBAction)buttonNormal:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = normalColor;
    
    if (button.tag == 1) {
        button.backgroundColor = normalNotifColor;
    }

}


- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
    
    /*
    [[heartButton titleLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [[lungButton titleLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [[diabetesButton titleLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [[customButton titleLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    */
    
    [self.view setNeedsLayout];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setScreenName:@"HomeViewController"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    
    heartButton.layer.cornerRadius = 10.0;
    lungButton.layer.cornerRadius = 10.0;
    diabetesButton.layer.cornerRadius = 10.0;
    customButton.layer.cornerRadius = 10.0;
    reminderButton.layer.cornerRadius = 10.0;
    
    heartButton.layer.drawsAsynchronously = YES;
    lungButton.layer.drawsAsynchronously = YES;
    diabetesButton.layer.drawsAsynchronously = YES;
    customButton.layer.drawsAsynchronously = YES;
    
    normalColor = heartButton.backgroundColor;
    normalNotifColor = reminderButton.backgroundColor;
    
    // change background colors when buttons are clicked
    
    [heartButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [heartButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    [heartButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    
    [lungButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [lungButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    [lungButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    
    [diabetesButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [diabetesButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    [diabetesButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    
    [customButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [customButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    [customButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    
    
    [reminderButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [reminderButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside];
    [reminderButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragOutside];
    reminderButton.tag = 1;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    heartButton.backgroundColor = normalColor;
    lungButton.backgroundColor = normalColor;
    diabetesButton.backgroundColor = normalColor;
    customButton.backgroundColor = normalColor;
    reminderButton.backgroundColor = normalNotifColor;
    
    // Display bell image and reminder button only if reminders are OFF
    NSLog(@"viewWillAppear");
    
    if ( ![[NSUserDefaults standardUserDefaults] boolForKey:MetasomeNotificationPrefKey] ) {
        reminderButton.hidden = NO;
        bellImageView.hidden = NO;
        NSLog(@"hiding buttons");
    } else {
        reminderButton.hidden = YES;
        bellImageView.hidden = YES;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)heartSelected:(id)sender {
    
    // sent hit data to google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"heart"          // Event label
                                                           value:nil] build]];    // Event value
    
    [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] heartList]];
    
    // Remember that this app has now been opened once and remember the selection
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:heartSelection forKey:@"lastSelection"];
    
    [[self paramViewController] setCurrentSelection:heartSelection];
    [[[self paramViewController] titleLabel] setText:@"Heart"];
    [self.paramViewController updateTitle:self.paramViewController.titleLabel];
    [self.paramViewController setNeedsStatusBarAppearanceUpdate];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [[self tabBarController] setSelectedIndex:1];
    
}

- (IBAction)lungSelected:(id)sender {
    
    // sent hit data to google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"lung"          // Event label
                                                           value:nil] build]];    // Event value
    
    
    [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] lungList]];
    
    // Remember that this app has now been opened once and remember the selection
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:lungSelection forKey:@"lastSelection"];
    
    [[self paramViewController] setCurrentSelection:lungSelection];
    
    [[self paramViewController] setCurrentSelection:lungSelection];
    self.paramViewController.titleLabel.text = @"Lung";
    [self.paramViewController updateTitle:[self.paramViewController titleLabel]];
    [self.paramViewController setNeedsStatusBarAppearanceUpdate];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [[self tabBarController] setSelectedIndex:1];
    
}

- (IBAction)diabetesSelected:(id)sender {
    
    // sent hit data to google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"metabolic"          // Event label
                                                           value:nil] build]];    // Event value
    
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:diabetesSelection forKey:@"lastSelection"];
    
    [[self paramViewController] setCurrentSelection:diabetesSelection];
    
    [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] diabetesList]];
    [[self paramViewController] setCurrentSelection:diabetesSelection];
    self.paramViewController.titleLabel.text = @"Metabolic";
    [self.paramViewController updateTitle:[self.paramViewController titleLabel]];
    [self.paramViewController setNeedsStatusBarAppearanceUpdate];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [[self tabBarController] setSelectedIndex:1];
    
}

- (IBAction)customSelected:(id)sender {
   
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:customSelection forKey:@"lastSelection"];
    
    [[self paramViewController] setCurrentSelection:customSelection];
    
    [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] customList]];
    
    [[self paramViewController] setCurrentSelection:customSelection];
    self.paramViewController.titleLabel.text = @"Mind";
    [self.paramViewController updateTitle:[self.paramViewController titleLabel]];
    [self.paramViewController setNeedsStatusBarAppearanceUpdate];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [[self tabBarController] setSelectedIndex:1];
}

- (IBAction)reminderButtonPressed:(id)sender {
    
    NotificationsDetailViewController *ndvc = [[NotificationsDetailViewController alloc] init];
    [[self navigationController] pushViewController:ndvc animated:YES];

}

@end
