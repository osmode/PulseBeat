//
//  HomeViewController.h
//  Metasome
//
//  Created by Omar Metwally on 9/13/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ParameterViewController;
typedef  enum {
    heartSelection,
    lungSelection,
    diabetesSelection,
    customSelection
} selectionTypeOnLaunch;

@interface HomeViewController : UIViewController
{
 
    __weak IBOutlet UIButton *heartButton;
    __weak IBOutlet UIButton *lungButton;
    __weak IBOutlet UIButton *diabetesButton;
    __weak IBOutlet UIButton *customButton;
    
}

// create pointer to pvc to change title before it loads
// this is necessary because pressing a button in HomeViewController
// manually changes the tab
@property (nonatomic, strong) ParameterViewController *paramViewController;

- (IBAction)heartSelected:(id)sender;
- (IBAction)lungSelected:(id)sender;
- (IBAction)diabetesSelected:(id)sender;
- (IBAction)customSelected:(id)sender;

@end
