//
//  ParameterViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface ParameterViewController : UITableViewController 
{
}

@property (nonatomic) selectionTypeOnLaunch currentSelection;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) UILabel *titleLabel;

-(IBAction)addNewItem:(id)sender;
-(void)updateTitle:(UILabel *)label;


@end
