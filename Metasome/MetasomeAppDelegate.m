//
//  MetasomeAppDelegate.m
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeAppDelegate.h"
#import "ParameterViewController.h"
#import "MetasomeDataPointStore.h"
#import "EventViewController.h"
#import "OptionsViewController.h"
#import "DetailViewController.h"
#import "HomeViewController.h"
#import "PhotoViewController.h"
#import "GraphView.h"

@implementation MetasomeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Handle launching from notification
    [application setApplicationIconBadgeNumber:0];
    
    /*
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        application.applicationIconBadgeNumber = 0;
    }
    */
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //MetasomeViewController *mvc = [[MetasomeViewController alloc] init];
    //[[self window] setRootViewController:mvc];
    
    HomeViewController *hvc = [[HomeViewController alloc] init];
    ParameterViewController *pvc = [[ParameterViewController alloc] init];
    EventViewController *evc = [[EventViewController alloc] init];
    OptionsViewController *ovc = [[OptionsViewController alloc] init];
    
    [hvc setParamViewController:pvc];
    
    UINavigationController *homeNavController = [[UINavigationController alloc] initWithRootViewController:hvc];
    parameterNavController = [[UINavigationController alloc]
                                             initWithRootViewController:pvc];
    
    UINavigationController *eventNavController = [[UINavigationController alloc] initWithRootViewController:evc];
    UINavigationController *optionsNavController = [[UINavigationController alloc] initWithRootViewController:ovc];

    /*
    UIColor *color = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0];
    
    [[homeNavController navigationBar] setBarTintColor:[UIColor redColor]];
    [[parameterNavController navigationBar] setBarTintColor:[UIColor redColor]];
    [[eventNavController navigationBar] setBarTintColor:[UIColor redColor]];
    [[optionsNavController navigationBar] setBarTintColor:[UIColor redColor]];
     */
    
    UIColor *navBarColor = [UIColor redColor];
    UIColor *navBarTextColor = [UIColor whiteColor];
    
    
    // set all navigation bars to navBarColor
    [[homeNavController navigationBar] setBarTintColor:navBarColor];
    [[parameterNavController navigationBar] setBarTintColor:navBarColor];
    [[eventNavController navigationBar] setBarTintColor:navBarColor];
    [[optionsNavController navigationBar] setBarTintColor:navBarColor];
    
    // set the text color of the navigation bars
    [[homeNavController navigationBar] setTintColor:navBarTextColor];
    [[parameterNavController navigationBar] setTintColor:navBarTextColor];
    [[eventNavController navigationBar] setTintColor:navBarTextColor];
    [[optionsNavController navigationBar] setTintColor:navBarTextColor];
    
    UITabBarItem *homeButton = [homeNavController tabBarItem];
    UITabBarItem *tbi = [parameterNavController tabBarItem];
    UITabBarItem *eventButton = [eventNavController tabBarItem];
    UITabBarItem *optionsButton  = [optionsNavController tabBarItem];
    
    UIImage *homeImage = [UIImage imageNamed:@"home.png"];
    UIImage *trackerImage = [UIImage imageNamed:@"tracker.png"];
    UIImage *eventImage = [UIImage imageNamed:@"diary.png"];
    UIImage *optionsImage = [UIImage imageNamed:@"options"];
    
    [homeButton setTitle:@"Home"];
    [homeButton setImage:homeImage];
    [tbi setTitle:@"Tracker"];
    [tbi setImage:trackerImage];
    [eventButton setTitle:@"Diary"];
    [eventButton setImage:eventImage];
    [optionsButton setImage:optionsImage];
    [optionsButton setTitle:@"Settings"];
    
    //[[self window] setRootViewController:navController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    NSArray *viewControllers = [NSArray arrayWithObjects: homeNavController, parameterNavController, eventNavController, optionsNavController, nil];
    
    //parameterNavController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.05 blue:0.65 alpha:0.75];
    //eventNavController.navigationBar.tintColor = [UIColor colorWithRed:1.0 green:0.4 blue:0 alpha:1.0];
    
    [tabBarController setViewControllers:viewControllers];
    
    // start
    
    int currentLaunchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
    
    if (currentLaunchCount == 0) {
        [tabBarController setSelectedIndex:0];
    } else {
        [tabBarController setSelectedIndex:1];
    }
        
    [tabBarController setDelegate:self];
    [[self window] setRootViewController:tabBarController];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];    
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //NSLog(@"didReceiveLocalNotification");
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Reminder" message:@"Remember to log your PulseBeat info!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
        application.applicationIconBadgeNumber = 0;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    BOOL success = [[MetasomeDataPointStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"Saving data points successful");
    } else {
        NSLog(@"Unable to save data points!");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
   // NSLog(@"current tab index: %i", [tabBarController selectedIndex]);
    //NSLog(@"changing to index: %i", [[tabBarController viewControllers] indexOfObjectIdenticalTo:viewController]);
    if ([tabBarController selectedIndex] != 1)
        [parameterNavController popToRootViewControllerAnimated:YES];
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }
    
    NSString *URLString = [url absoluteString];
    [[NSUserDefaults standardUserDefaults] setObject:URLString forKey:@"url"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

/*
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIViewController *presented;
    
    if (self.window.rootViewController) {
        presented = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
        

        //orientations = [presented supportedInterfaceOrientations];
    }
    
    //return orientations;
    //NSLog(@"current window: %@",[window.rootViewController.view description]);
    
    if([window.rootViewController.view isKindOfClass:[GraphView class]]) {
        NSLog(@"class of kind OptionsViewController");
        return UIInterfaceOrientationMaskPortrait;
    }

    return UIInterfaceOrientationMaskAll;
    
}
*/


@end
