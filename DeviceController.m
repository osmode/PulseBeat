//
//  DeviceController.m
//  PulseBeat
//
//  Created by Omar Metwally on 10/21/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "DeviceController.h"
#import "FitbitLoginViewController.h"
#import "OAuth1Controller.h"
#import "FitbitApiDataStore.h"
#import "WithingsAPIDataStore.h"
#import "WithingsOAuth1Controller.h"
#import "MetasomeDataPointStore.h"
#import "TextFormatter.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface DeviceController ()

@end

@implementation DeviceController
@synthesize selectedActionBlock, oauth1Controller, withingsOAuth1Controller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [TextFormatter formatTitleLabel:titleLabel withTitle:@"Sync Devices"];
        [[self navigationItem] setTitleView:titleLabel];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    normalColor = fitbitButton.backgroundColor;
    
    self.screenName = @"DeviceController";
    
    fitbitButton.layer.cornerRadius = 10.0;
    withingsButton.layer.cornerRadius = 10.0;
    
    [fitbitButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
    [fitbitButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    [fitbitButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    
    [withingsButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
    [withingsButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    [withingsButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    if (normalColor) {
        fitbitButton.backgroundColor = normalColor;
        withingsButton.backgroundColor = normalColor;
    }
}

-(IBAction)highlightButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    button.backgroundColor = [UIColor greenColor];
}

-(IBAction)normalButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    button.backgroundColor = normalColor;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fitbitButtonPressed:(id)sender {
    
    NSLog(@"fitbitButtonPressed");
    
    // sent hit data to google analytics
    /*
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"fitbitSyncButton"          // Event label
                                                           value:nil] build]];    // Event value
     */
    
    FitbitLoginViewController *flvc = [[FitbitLoginViewController alloc] init];
    
    
    self.navigationController.delegate = self;
    
    [flvc setCompletionBlock:^{
        
        [self.oauth1Controller loginWithWebView:flvc.webView completion:^(NSDictionary *oauthTokens, NSError *error) {
            
            if (!error) {
                
                // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
                self.oauthToken = oauthTokens[@"oauth_token"];
                self.oauthTokenSecret = oauthTokens[@"oauth_token_secret"];
                
                NSLog(@"oauthToken = %@", self.oauthToken);
                
                UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                aiv.color = [UIColor grayColor];
                aiv.center = [[flvc webView] center];
                [flvc.webView addSubview:aiv];
                [aiv startAnimating];
                
                // clear all Fitbit data from database
                [[MetasomeDataPointStore sharedStore] deletePointsFromApi:@"Fitbit" fromDate:nil toDate:nil];
                
                // populate local database with fitbit data
                NSLog(@"calling getStepData");
                [[FitbitApiDataStore sharedStore] getStepData:self.oauthToken oauthSecretIn:self.oauthTokenSecret];
                [[FitbitApiDataStore sharedStore] getDistanceData:self.oauthToken oauthSecretIn:self.oauthTokenSecret];
                [[FitbitApiDataStore sharedStore] getWeightData:self.oauthToken oauthSecretIn:self.oauthTokenSecret];
                [[FitbitApiDataStore sharedStore] getSleepDurationData:self.oauthToken oauthSecretIn:self.oauthTokenSecret];
                
                [[FitbitApiDataStore sharedStore] getBMIData:self.oauthToken oauthSecretIn:self.oauthTokenSecret];
                
                // save changes to database
                [[MetasomeDataPointStore sharedStore] saveChanges];
                
                [aiv stopAnimating];
                aiv = nil;
                
                
            }
            else
            {
                NSLog(@"Error authenticating: %@", error.localizedDescription);
                [self showConnectionError:error.localizedDescription];
            }
            
            /*
            [self dismissViewControllerAnimated:YES completion: ^{
                self.oauth1Controller = nil;
            }];
            */
            
        }];
    }];
    
    [[self navigationController] pushViewController:flvc animated:YES];

}

- (IBAction)withingsButtonPressed:(id)sender {
    
    // sent hit data to google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"withingsSyncButton"          // Event label
                                                           value:nil] build]];    // Event value
    
    BOOL loadedWithoutError = NO;
    
    FitbitLoginViewController *flvc = [[FitbitLoginViewController alloc] init];
    self.navigationController.delegate = self;
    
    [flvc setCompletionBlock:^{
        
        [self.withingsOAuth1Controller loginWithWebView:flvc.webView completion:^(NSDictionary *oauthTokens, NSError *error) {
            
            if (!error) {
                // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
                self.oauthToken = oauthTokens[@"oauth_token"];
                self.oauthTokenSecret = oauthTokens[@"oauth_token_secret"];
                
                NSLog(@"oauthToken: %@, oauthTokenSecret: %@", self.oauthToken, self.oauthTokenSecret);
                
                UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                aiv.color = [UIColor grayColor];
                aiv.center = [[flvc webView] center];
                [flvc.webView addSubview:aiv];
                [aiv startAnimating];
                
                [[WithingsApiDataStore sharedStore] getBloodPressureData:self.oauthToken oauthSecretIn:self.oauthTokenSecret userID:[self.withingsOAuth1Controller userid_class] withCompletion:^{
                    
                    [aiv stopAnimating];
                    
                }];
            }
            else
            {
                NSLog(@"Error authenticating: %@", error.localizedDescription);
                [self showConnectionError:error.localizedDescription];
            }
            [self dismissViewControllerAnimated:YES completion: ^{
                self.withingsOAuth1Controller = nil;
            }];
        }];
    }];
    
    // push FitbitLoginViewController only if there are no errors
    [[self navigationController] pushViewController:flvc animated:YES];

    
}

- (OAuth1Controller *)oauth1Controller
{
    if (oauth1Controller == nil) {
        oauth1Controller = [[OAuth1Controller alloc] init];
    }
    return oauth1Controller;
}

- (WithingsOAuth1Controller *)withingsOAuth1Controller
{
    if (withingsOAuth1Controller == nil) {
        withingsOAuth1Controller = [[WithingsOAuth1Controller alloc] init];
    }
    return withingsOAuth1Controller;
}

-(void)showConnectionError:(NSString *)localizedDescription
{
    NSString *displayString = [localizedDescription stringByAppendingString:@" Check your internet connection and try again."];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:displayString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];

}

@end
