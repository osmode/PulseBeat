//
//  LoginScreenViewController.m
//  Metasome
//
//  Created by Omar Metwally on 9/17/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "LoginScreenViewController.h"
#import "MetasomeParameterStore.h"


@interface LoginScreenViewController ()

@end

@implementation LoginScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)saveEmail:(id)sender {
    [[[MetasomeParameterStore sharedStore] parameterArray] addObject:[emailField text]];
    [[MetasomeParameterStore sharedStore] saveChanges];
    
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)cancelSelected:(id)sender {
    
    int currentLoadCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    [[NSUserDefaults standardUserDefaults] setInteger:(currentLoadCount + 1) forKey:@"launchCount"];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backgroundTouched:(id)sender {
    [[self view] endEditing:YES];
}
@end
