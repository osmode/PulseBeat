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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fitbitButtonPressed:(id)sender {
    
    FitbitLoginViewController *flvc = [[FitbitLoginViewController alloc] init];
    
    int __block loadedWithoutError = 3;
    
    self.navigationController.delegate = self;
    
    [flvc setCompletionBlock:^{
        
        [self.oauth1Controller loginWithWebView:flvc.webView completion:^(NSDictionary *oauthTokens, NSError *error) {
            if (!error) {
                
                // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
                self.oauthToken = oauthTokens[@"oauth_token"];
                self.oauthTokenSecret = oauthTokens[@"oauth_token_secret"];
                
                UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                aiv.color = [UIColor grayColor];
                aiv.center = [[flvc webView] center];
                [flvc.webView addSubview:aiv];
                [aiv startAnimating];
                
                // clear all Fitbit data from database
                [[MetasomeDataPointStore sharedStore] deletePointsFromApi:@"Fitbit" fromDate:nil toDate:nil];
                
                // populate local database with fitbit data
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
                loadedWithoutError = 2;
                NSLog(@"loadedWithoutError: %i", loadedWithoutError);
                
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
    
    if (loadedWithoutError == 3) {
        [[self navigationController] pushViewController:flvc animated:YES];
    }
    
}

- (IBAction)withingsButtonPressed:(id)sender {
    
    BOOL loadedWithoutError = NO;
    
    FitbitLoginViewController *flvc = [[FitbitLoginViewController alloc] init];
    self.navigationController.delegate = self;
    [[flvc navigationItem] setTitle:@"Sync Withings data"];
    
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
