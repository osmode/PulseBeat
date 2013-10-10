//
//  FitbitApiDataStore.m
//  PulseBeat
//
//  Created by Omar Metwally on 10/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "FitbitApiDataStore.h"
#import "OAuth1Controller.h"

@implementation FitbitApiDataStore

+(FitbitApiDataStore *)sharedStore
{
    static FitbitApiDataStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
        
    }
    
    return sharedStore;
    
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)getStepData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn
{
    NSString *path = @"1/user/-/activities/steps/date/today/1y.json";
    
    NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:path parameters:nil HTTPmethod:@"GET"
        oauthToken:oauthTokenIn
        oauthSecret:oauthSecretIn];
    
    [NSURLConnection sendAsynchronousRequest:preparedRequest
        queue:NSOperationQueue.mainQueue
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"path35 %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   
                if (error) {
                    NSLog(@"Error in API request: %@", error.localizedDescription);
                } else {
                    
                }
                
                });
            }];
}


@end
