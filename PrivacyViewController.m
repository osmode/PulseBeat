//
//  PrivacyViewController.m
//  PulseBeat
//
//  Created by Omar Metwally on 10/23/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "PrivacyViewController.h"
#import "GAI.h"
#import "TextFormatter.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [TextFormatter formatTitleLabel:titleLabel withTitle:@"Privacy"];
        [[self navigationItem] setTitleView:titleLabel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    backgroundLabel.layer.cornerRadius = 10.0;
    [sendSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    if ([[GAI sharedInstance] optOut])
        sendSwitch.on = NO;
}

-(void)switchChanged:(id)sender
{
    UISwitch *inputSwitch = (UISwitch *)sender;
    if (inputSwitch.on)
        [[GAI sharedInstance] setOptOut:NO];
    else
        [[GAI sharedInstance] setOptOut:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
