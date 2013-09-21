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


@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize paramViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [TextFormatter formatTitleLabel:titleLabel withTitle:@"PulseBeat"];
        [[self navigationItem] setTitleView:titleLabel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)heartSelected:(id)sender {
    [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] heartList]];
    
    [[self paramViewController] setCurrentSelection:heartSelection];
    [[[self paramViewController] titleLabel] setText:@"Heart"];
    [self.paramViewController updateTitle:self.paramViewController.titleLabel];
    [self.paramViewController setNeedsStatusBarAppearanceUpdate];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [[self tabBarController] setSelectedIndex:1];
    
    // Remember that this app has now been opened once and remember the selection
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:heartSelection forKey:@"lastSelection"];
}

- (IBAction)lungSelected:(id)sender {
    [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] lungList]];
    
    [[self paramViewController] setCurrentSelection:lungSelection];
    self.paramViewController.titleLabel.text = @"Lung";
    [self.paramViewController updateTitle:[self.paramViewController titleLabel]];
    [self.paramViewController setNeedsStatusBarAppearanceUpdate];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [[self tabBarController] setSelectedIndex:1];
    
    // Remember that this app has now been opened once and remember the selection
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:lungSelection forKey:@"lastSelection"];
    
    [[self paramViewController] setCurrentSelection:lungSelection];
    
    NSLog(@"setting lastSelection to %i ", [[NSUserDefaults standardUserDefaults] integerForKey:@"lastSelection"]);

}

- (IBAction)diabetesSelected:(id)sender {
    [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] diabetesList]];
    [[self paramViewController] setCurrentSelection:diabetesSelection];
    self.paramViewController.titleLabel.text = @"Metabolic";
    [self.paramViewController updateTitle:[self.paramViewController titleLabel]];
    [self.paramViewController setNeedsStatusBarAppearanceUpdate];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [[self tabBarController] setSelectedIndex:1];
        
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:diabetesSelection forKey:@"lastSelection"];
    
    [[self paramViewController] setCurrentSelection:diabetesSelection];
    
    NSLog(@"setting lastSelection to %i ", [[NSUserDefaults standardUserDefaults] integerForKey:@"lastSelection"]);


}

- (IBAction)customSelected:(id)sender {
    [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] customList]];
    
    [[self paramViewController] setCurrentSelection:customSelection];
    self.paramViewController.titleLabel.text = @"Mind";
    [self.paramViewController updateTitle:[self.paramViewController titleLabel]];
    [self.paramViewController setNeedsStatusBarAppearanceUpdate];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [[self tabBarController] setSelectedIndex:1];
    
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:customSelection forKey:@"lastSelection"];
    
    [[self paramViewController] setCurrentSelection:customSelection];
    
    NSLog(@"setting lastSelection to %i ", [[NSUserDefaults standardUserDefaults] integerForKey:@"lastSelection"]);
    
    

    
}
@end
