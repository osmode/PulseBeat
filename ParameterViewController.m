//
//  ParameterViewController.m
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "ParameterViewController.h"
#import "MetasomeParameterStore.h"
#import "MetasomeParameter.h"
#import "MetasomeDataPointStore.h"
#import "MetasomeDataPoint.h"
#import "DetailViewController.h"
#import "DetailViewController_slider.h"
#import "NewParameterViewController.h"
#import "MetasomeBloodPressureViewController.h"
#import "HomeViewController.h"
#import "LoginScreenViewController.h"
#import "TextFormatter.h"


@implementation ParameterViewController
@synthesize currentSelection, titleString, titleLabel;

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}
     
-(id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
               initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
               target:self action:@selector(addNewItem:)];
        
        [[self navigationItem] setRightBarButtonItem:bbi];
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.75 green:0.90 blue:0.22 alpha:1.0];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
    }
    
    return self;
}
+(void) initialize
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"launchCount"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

}

-(void)addNewItem:(id)sender
{
    NewParameterViewController *npvc = [[NewParameterViewController alloc] init];
    
    [[self navigationController] pushViewController:npvc animated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // Check if app was previously loaded and recall the last selection
    selectionTypeOnLaunch lastSelection = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastSelection"];
    
    [self setCurrentSelection:lastSelection];
    [self updateTitle:titleLabel];
    
    // If the current list is empty, set to heart list by default
    if ([[self tableView] numberOfRowsInSection:0] == 0) {
        [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] heartList]];
    }
    
    [[self tableView] reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    switch ([self currentSelection]) {
        case heartSelection:
            [[MetasomeParameterStore sharedStore] setCurrentList:[[[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:0] valueForKey:@"list"]];
            break;
            
        case lungSelection:
            [[MetasomeParameterStore sharedStore] setCurrentList:[[[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:1] valueForKey:@"list"]];
            break;
            
        case diabetesSelection:
            [[MetasomeParameterStore sharedStore] setCurrentList:[[[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:2] valueForKey:@"list"]];
            break;
            
        case customSelection:
            [[MetasomeParameterStore sharedStore] setCurrentList:[[[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:3] valueForKey:@"list"]];
            break;
            
        default:
            [[MetasomeParameterStore sharedStore] setCurrentList:[[MetasomeParameterStore sharedStore] heartList]];
            //[[MetasomeParameterStore sharedStore] setCurrentList:[[[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:0] valueForKey:@"list"]];
            
    }

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    int currentLaunchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];

    // Launch HomeViewController modally only if loading app for the first time
    
    if (currentLaunchCount == 0) {
       HomeViewController *hvc = [[HomeViewController alloc] init];
        [self presentViewController:hvc animated:YES completion:nil];
        //LoginScreenViewController *lvc = [[LoginScreenViewController alloc] init];
      // [self presentViewController:lvc animated:YES completion:nil];
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Index of  MetasomeParameterStore.sharedStore.parameterArray
    // and Contents
    // 0 -- vitalsArrayDict
    // 1 -- mindArrayDict
    // 2 -- symptomsArrayDict
    // The indices above correspond to UITableView section numbers
    
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        
        [[[MetasomeParameterStore sharedStore] currentList] removeObjectAtIndex:indexPath.row];
        
        [[MetasomeParameterStore sharedStore] saveChanges];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    
    //return [[[MetasomeParameterStore sharedStore] sections] count];
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    /*
    NSDictionary *dictionary = [[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    NSString *cellValue = [[array objectAtIndex:indexPath.row] parameterName];
    */
    
    MetasomeParameter *p = [[[MetasomeParameterStore sharedStore] currentList] objectAtIndex:indexPath.row];
        
    NSString *cellValue = [p parameterName];
    [[cell textLabel] setText:cellValue];
    
    // Check if it's time to reset the checkmark each time the cell loads
    [p resetCheckmark];
    
    // highlight color when cell is selected
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    if ([p checkedStatus] == YES) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    if ([p checkedStatus] == NO) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[MetasomeParameterStore sharedStore] currentList] count];
}


-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // Don't allow changing parameters' categories
    
    if ( [sourceIndexPath section] != [destinationIndexPath section] )
        return;
    
    [[MetasomeParameterStore sharedStore] moveItemAtIndex:[sourceIndexPath row] toIndex:[destinationIndexPath row] inSection:[sourceIndexPath section]];
    [[MetasomeParameterStore sharedStore] saveChanges];
    
    
}
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController;
    DetailViewController_slider *detailViewController_slider;
    
    /*
    NSDictionary *dictionary = [[[MetasomeParameterStore sharedStore] parameterArray] objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    MetasomeParameter *p = [array objectAtIndex:indexPath.row];
    */
    
    MetasomeParameter *p = [[[MetasomeParameterStore sharedStore] currentList] objectAtIndex:indexPath.row];
    
    // Set parameter as marked
    //[p setCheckedStatus:YES];
    //[p setLastChecked:[NSDate date]];
    //[[MetasomeParameterStore sharedStore] saveChanges];
    
    // Create block to check for presence of at least one data point
    BOOL (^block)(void) = ^ {
        
        NSArray *points = [[MetasomeDataPointStore sharedStore] allPoints];
        int counter = 0;
        
        for (MetasomeDataPoint *dp in points) {
            if ( [[dp parameterName] isEqualToString:[p parameterName]] )
                counter +=1;
        }
                
        if (counter >0) {
            [[MetasomeDataPointStore sharedStore] setParameterToGraph:p];
            return YES;
        }
            
        else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:(@"No data points entered yet!") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [av show];
            
            return NO;
        }
    };
    
    switch ([p inputType]) {
        case ParameterInputSlider:
            detailViewController_slider = [[DetailViewController_slider alloc] init];
            [detailViewController_slider setIsDataPointStoreNonEmpty:block];
            
            [detailViewController_slider setParameter:p];
            [[self navigationController] pushViewController:detailViewController_slider animated:YES];
            break;
        
        case ParameterBloodPressure:
        {
            MetasomeBloodPressureViewController *bpvc = [[MetasomeBloodPressureViewController alloc] init];
            [bpvc setIsDataPointStoreNonEmpty:block];
            [bpvc setParameter:p];
            [[self navigationController] pushViewController:bpvc animated:YES];
            break;
        }
            
        default:
            detailViewController = [[DetailViewController alloc] init];
            [detailViewController setIsDataPointStoreNonEmpty:block];
            
            [detailViewController setParameter:p];
            [[self navigationController] pushViewController:detailViewController animated:YES];
            break;
    }
    
}

-(void)updateTitle:(UILabel *)label
{
    
    switch ([self currentSelection]) {
        case heartSelection:
            [self setTitleString:@"Heart"];
            break;
        case lungSelection:
            [self setTitleString:@"Lung"];
            break;
        case diabetesSelection:
            [self setTitleString:@"Metabolic"];
            break;
        case customSelection:
            [self setTitleString:@"Mind"];
            break;
    }
    
    
    [TextFormatter formatTitleLabel:label withTitle:[self titleString]];
    [[self navigationItem] setTitleView:label];
}

@end
