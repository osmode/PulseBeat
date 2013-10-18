//
//  WithingsAPIDataStore.m
//  PulseBeat
//
//  Created by Omar Metwally on 10/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "WithingsAPIDataStore.h"
#import "WithingsJSONData.h"
#import "WithingsOAuth1Controller.h"
#import "MetasomeDataPointStore.h"

@implementation WithingsApiDataStore

+(WithingsApiDataStore *)sharedStore
{
    static WithingsApiDataStore *sharedStore = nil;
    
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

- (void)getBloodPressureData:(NSString *)oauthTokenIn oauthSecretIn:(NSString *)oauthSecretIn userID:(NSString *)userid withCompletion:(void (^)(void))completion
{
    NSString *path = @"measure";
    NSMutableDictionary *moreParams = [[NSMutableDictionary alloc] init];
    [moreParams setValue:@"getmeas" forKey:@"action"];
    
    [moreParams setValue:userid forKey:@"userid"];
    
    NSURLRequest *preparedRequest = [WithingsOAuth1Controller preparedRequestForPath:path
                                                                  parameters:moreParams
                                                                  HTTPmethod:@"GET"
                                                                  oauthToken:oauthTokenIn
                                                                 oauthSecret:oauthSecretIn];
        
    [NSURLConnection sendAsynchronousRequest:preparedRequest
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   NSLog(@"path35 %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   
                                   if (error) {
                                       
                                       NSLog(@"Error in API request: %@", error.localizedDescription);
                                       return;
                                   }
                                   
                                   NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   
                                   WithingsJSONData *withingsJSONData = [[WithingsJSONData alloc] initWithDictionary:d dataName:@"body"];
                                   
                                   // clear pre-existing Withings data before populating DB with new data
                                   [[MetasomeDataPointStore sharedStore] deletePointsFromApi:@"Withings" fromDate:nil toDate:nil];
                                   
                                   [withingsJSONData saveToDataPointStore:@"test"];
                                   
                                   completion();
                                  
                               });
                           }];

}


@end
