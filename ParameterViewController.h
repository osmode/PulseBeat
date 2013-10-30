//
//  ParameterViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@class MetasomeParameter;
@interface ParameterViewController : UITableViewController <UITableViewDelegate>
{
}

@property (nonatomic) selectionTypeOnLaunch currentSelection;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) BOOL (^isDataPointStoreNonEmpty)(void);

-(IBAction)addNewItem:(id)sender;
-(void)updateTitle:(UILabel *)label;
-(UIImage *)getGamificationImage:(MetasomeParameter *)parameter;

@end
