//
//  MetasomeAppDelegate.h
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParameterViewController.h"

@interface MetasomeAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
    UINavigationController *parameterNavController;
}
@property (strong, nonatomic) UIWindow *window;

@end
