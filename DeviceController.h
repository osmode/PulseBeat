//
//  DeviceController.h
//  PulseBeat
//
//  Created by Omar Metwally on 10/21/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OAuth1Controller, WithingsOAuth1Controller;
@interface DeviceController : UIViewController
{
    
}

@property (nonatomic, copy) void (^selectedActionBlock)(void);
@property (nonatomic, strong) OAuth1Controller *oauth1Controller;
@property (nonatomic, strong) WithingsOAuth1Controller *withingsOAuth1Controller;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;

- (IBAction)fitbitButtonPressed:(id)sender;
- (IBAction)withingsButtonPressed:(id)sender;
- (OAuth1Controller *)oauth1Controller;
- (WithingsOAuth1Controller *)withingsOAuth1Controller;


@end
