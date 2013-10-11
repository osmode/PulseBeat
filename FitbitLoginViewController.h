//
//  FitbitLoginViewController.h
//  PulseBeat
//
//  Created by Omar Metwally on 10/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FitbitLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, copy) void (^completionBlock)(void);

@end
