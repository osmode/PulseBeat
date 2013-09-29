//
//  OptionsViewController.m
//  Metasome
//
//  Created by Omar Metwally on 8/23/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "OptionsViewController.h"
#import "MetasomeParameterStore.h"
#import "MetasomeParameterStore.h"
#import "MetasomeDataPointStore.h"
#import "MetasomeDataPoint.h"
#import "NotificationsDetailViewController.h"
#import "TextFormatter.h"


@implementation OptionsViewController
@synthesize selectedActionBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [TextFormatter formatTitleLabel:titleLabel withTitle:@"Settings"];
        [[self navigationItem] setTitleView:titleLabel];
        MetasomeNotificationPrefKey = @"MetasomeNotificationPrefKey";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib *nibSwitch = [UINib nibWithNibName:@"OptionsSwitchCell" bundle:nil];
    UINib *nibNormal = [UINib nibWithNibName:@"OptionsNormalCell" bundle:nil];
    
    // Register this NIB which contains the cell
    [tableView  registerNib:nibSwitch forCellReuseIdentifier:@"OptionsSwitchCell"];
    [tableView registerNib:nibNormal forCellReuseIdentifier:@"OptionsNormalCell"];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteToday:(id)sender {
    
    /*
    for (MetasomeDataPoint *dp in [[MetasomeDataPointStore sharedStore] allPoints] )
    {
        if ( [[dp date] timeIntervalSince1970] > today ) {
            
            [discardedItems addObject:dp];
        }
            
    }

    [[[MetasomeDataPointStore sharedStore] allPoints] removeObjectsInArray:discardedItems];
     */

}

- (IBAction)deleteAll:(id)sender {
        
    NSMutableArray *allPoints = [[MetasomeDataPointStore sharedStore] allPoints];
    
    [allPoints removeAllObjects];
         
}

- (void)resetParameters {
    NSLog(@"resetting paramter lists");
    [[MetasomeParameterStore sharedStore] loadDefaultParameters];
    
    [[MetasomeParameterStore sharedStore] saveChanges];
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"MetasomeNotificationPrefKey"] )
        NSLog(@"ON");
    else
        NSLog(@"OFF");
    
        
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:  // Notifications cell
            [[cell textLabel] setText:@"Reminders"];
            if ( [[NSUserDefaults standardUserDefaults] boolForKey:MetasomeNotificationPrefKey] ) {
                [[cell detailTextLabel] setText:@"Reminders on"];
                [[cell detailTextLabel] setTextColor:[UIColor redColor]];
            } else {
                [[cell detailTextLabel] setText:@"Reminders off"];
                [[cell detailTextLabel] setTextColor:[UIColor blueColor]];
                
            }
            break;
            
        case 1:  // Reset default parameters
            [[cell textLabel] setText:@"Reset default lists"];
            break;
        case 2:  //Delete all records cell
            [[cell textLabel] setText:@"Delete all records"];
            break;
        case 3:
            [[cell textLabel] setText:@"Delete today's records"];
            break;
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return  cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            NotificationsDetailViewController *ndvc = [[NotificationsDetailViewController alloc] init];
            [[self navigationController] pushViewController:ndvc animated:YES];
            
            break;
        }
        case 1:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setSelectedActionBlock:^{
            
                [self resetParameters];
                
            }];
            
            [self promptWithString:@"Are you sure you want to reset all lists to default? This will delete any custom lists."];
            
            break;
        }
        case 2:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [self setSelectedActionBlock:^{
                [[MetasomeDataPointStore sharedStore] deleteAllPoints];
            
            }];
            
            [self promptWithString:@"Are you sure you want to delete all points? This action cannot be undone."];
            
            break;
        }
        case 3:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setSelectedActionBlock:^{
                [[MetasomeDataPointStore sharedStore] deleteTodayPoints];
            }];
            
            [self promptWithString:@"Are you sure you want to delete all points entered today? This action cannot be undone"];
            break;
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the first button is cancel
    if (buttonIndex == 0)
        return;
    
    selectedActionBlock();
    
    // Destroy pointer to prevent retain cycle introduced by
    // capturing self (while setting block)
    [self setSelectedActionBlock:nil];
}
/* create current Block property and execute when UIAlertView delegate methods are called */

-(void)promptWithString:(NSString *)prompt
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Warning" message:prompt delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil];
    [av setDelegate:self];
    [av show];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


@end
