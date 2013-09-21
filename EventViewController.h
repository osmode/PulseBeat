//
//  EventViewController.h
//  Metasome
//
//  Created by Omar Metwally on 8/21/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : UITableViewController <UITextFieldDelegate>
{
    
}

@property (nonatomic, strong) UILabel *emptyListLabel;

-(void)addNewItem;

@end
