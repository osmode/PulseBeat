//
//  EventViewController.m
//  Metasome
//
//  Created by Omar Metwally on 8/21/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "EventViewController.h"
#import "MetasomeEventStore.h"
#import "MetasomeEvent.h"
#import "EventDetailViewController.h"
#import "NewEventViewController.h"
#import "TextFormatter.h"

@implementation EventViewController
@synthesize emptyListLabel;

-(id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        //[[self navigationItem] setTitle:@"Diary"];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
        
        [[self navigationItem] setRightBarButtonItem:bbi];
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        emptyListLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 110, 250, 50)];
        emptyListLabel.backgroundColor = [UIColor clearColor];
        emptyListLabel.numberOfLines = 2;
        emptyListLabel.text = @"No events entered yet.\nPress the [+] button to get started";
        emptyListLabel.textColor = [UIColor darkGrayColor];
        emptyListLabel.textAlignment = NSTextAlignmentCenter;
        emptyListLabel.font = [UIFont fontWithName:@"Avenir" size:22.0];
        emptyListLabel.adjustsFontSizeToFitWidth = YES;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [TextFormatter formatTitleLabel:titleLabel withTitle:@"Diary"];
        [[self navigationItem] setTitleView:titleLabel];
        
    }
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] addSubview:emptyListLabel];
    
    //UIColor *clr = [UIColor colorWithRed:0.875 green:0.88 blue:0.91 alpha:1.0];
    //[[self view] setBackgroundColor:clr];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[MetasomeEventStore sharedStore] allEvents] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    MetasomeEvent *event = [[[MetasomeEventStore sharedStore] allEvents] objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[event title]];
    if ([event visible]) {
        [[cell detailTextLabel] setText:@"Visible"];
        cell.detailTextLabel.textColor = [UIColor redColor];
    } else {
        [[cell detailTextLabel] setText:@"Invisible"];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    //[[cell imageView] setImage
    
    return cell;
}
    
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        MetasomeEventStore *mes = [MetasomeEventStore sharedStore];
        NSArray *events = [mes allEvents];
        MetasomeEvent *event = [events objectAtIndex:[indexPath row]];
        [mes removeEvent:event];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
    
    if ([[[MetasomeEventStore sharedStore] allEvents] count] > 0) {
        [emptyListLabel setHidden:YES];
        
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[MetasomeEventStore sharedStore] moveItemAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark - Table view delegate
-(void)addNewItem
{
    NewEventViewController *nevc = [[NewEventViewController alloc] init];
    [[self navigationController] pushViewController:nevc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewEventViewController *nev = [[NewEventViewController alloc] init];
    [nev setEventSelected:[[[MetasomeEventStore sharedStore] allEvents] objectAtIndex:indexPath.row]];
    [[self navigationController] pushViewController:nev animated:YES];
    
    /*
    EventDetailViewController *edvc = [[EventDetailViewController alloc] init];
    [[self navigationController] pushViewController:edvc animated:YES];
     */
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
