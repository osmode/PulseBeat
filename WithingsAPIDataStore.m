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

- (void)getBloodPressureData:(NSString *)oauthTokenIn oauthSecretIn:(NSString *)oauthSecretIn
{
    NSString *path = @"measure";
    NSMutableDictionary *moreParams = [[NSMutableDictionary alloc] init];
    [moreParams setValue:@"getmeas" forKey:@"action"];
    
    [moreParams setValue:@"2395114" forKey:@"userid"];
    
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
                                   
                                   [withingsJSONData saveToDataPointStore:@"test"];
                                   
                                   //[withingsJSONData sa
                                   //NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //NSLog(@"outputString: %@", outputString);
                                   
                                   // convert returned data to JSON and parse
                                   //NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   //WithingsJSONData *withingsJSONData = [[WithingsJSONData alloc] initWithDictionary:d dataName:<#(NSString *)#>
                               });
                           }];

}


@end
