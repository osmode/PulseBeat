//
//  HomeViewController.h
//  Metasome
//
//  Created by Omar Metwally on 9/13/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class ParameterViewController;
typedef  enum {
    heartSelection,
    lungSelection,
    diabetesSelection,
    customSelection
} selectionTypeOnLaunch;

@interface HomeViewController : GAITrackedViewController
{
 
    __weak IBOutlet UIButton *heartButton;
    __weak IBOutlet UIButton *lungButton;
    __weak IBOutlet UIButton *diabetesButton;
    __weak IBOutlet UIButton *customButton;
    
    UIColor *normalColor, *normalNotifColor;
    NSString *MetasomeNotificationPrefKey;
}

// create pointer to pvc to change title before it loads
// this is necessary because pressing a button in HomeViewController
// manually changes the tab
@property (nonatomic, strong) ParameterViewController *paramViewController;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;
@property (weak, nonatomic) IBOutlet UIImageView *bellImageView;


- (IBAction)heartSelected:(id)sender;
- (IBAction)lungSelected:(id)sender;
- (IBAction)diabetesSelected:(id)sender;
- (IBAction)customSelected:(id)sender;
- (IBAction)reminderButtonPressed:(id)sender;


@end
