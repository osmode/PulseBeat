//
//  FitbitApiDataStore.m
//  PulseBeat
//
//  Created by Omar Metwally on 10/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "FitbitApiDataStore.h"
#import "FitbitJSONData.h"
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
                
                //NSLog(@"path35 %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                if (error) {
                    NSLog(@"Error in API request: %@", error.localizedDescription);
                } else {
                    
                    // Turn JSON data into basic model objects
                    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    //NSLog(@"count: %i", [[d objectForKey:@"activities-steps"] count]);
                    
                    FitbitJSONData *fitbitJSONData = [[FitbitJSONData alloc] initWithDictionary:d dataName:@"activities-steps"];
                    
                    [fitbitJSONData saveToDataPointStore:@"Steps"];
                }
                
                });
            }];
}

- (void)getDistanceData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn
{
    NSString *path = @"1/user/-/activities/distance/date/today/1y.json";
    
    NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:path parameters:nil HTTPmethod:@"GET"
                                                                  oauthToken:oauthTokenIn
                                                                 oauthSecret:oauthSecretIn];
    
    [NSURLConnection sendAsynchronousRequest:preparedRequest
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   //NSLog(@"path35 %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   
                                   if (error) {
                                       NSLog(@"Error in API request: %@", error.localizedDescription);
                                   } else {
                                       
                                       // Turn JSON data into basic model objects
                                       NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       //NSLog(@"count: %i", [[d objectForKey:@"activities-steps"] count]);
                                       
                                       FitbitJSONData *fitbitJSONData = [[FitbitJSONData alloc] initWithDictionary:d dataName:@"activities-distance"];
                                       
                                       [fitbitJSONData saveToDataPointStore:@"Distance"];
                                   }
                                   
                               });
                           }];
}

- (void)getWeightData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn
{
    NSString *path = @"1/user/-/body/weight/date/today/1y.json";
    
    NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:path parameters:nil HTTPmethod:@"GET"
                                                                  oauthToken:oauthTokenIn
                                                                 oauthSecret:oauthSecretIn];
    
    [NSURLConnection sendAsynchronousRequest:preparedRequest
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   //NSLog(@"path35 %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   
                                   if (error) {
                                       NSLog(@"Error in API request: %@", error.localizedDescription);
                                   } else {
                                       
                                       // Turn JSON data into basic model objects
                                       NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       //NSLog(@"count: %i", [[d objectForKey:@"activities-steps"] count]);
                                       
                                       FitbitJSONData *fitbitJSONData = [[FitbitJSONData alloc] initWithDictionary:d dataName:@"body-weight"];
                                       
                                       [fitbitJSONData saveToDataPointStore:@"Weight"];
                                   }
                                   
                               });
                           }];
}

- (void)getBMIData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn
{
    NSString *path = @"1/user/-/body/bmi/date/today/1y.json";
    
    NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:path parameters:nil HTTPmethod:@"GET"
                                                                  oauthToken:oauthTokenIn
                                                                 oauthSecret:oauthSecretIn];
    
    [NSURLConnection sendAsynchronousRequest:preparedRequest
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   //NSLog(@"path35 %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   
                                   if (error) {
                                       NSLog(@"Error in API request: %@", error.localizedDescription);
                                   } else {
                                       
                                       // Turn JSON data into basic model objects
                                       NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       //NSLog(@"count: %i", [[d objectForKey:@"activities-steps"] count]);
                                       
                                       FitbitJSONData *fitbitJSONData = [[FitbitJSONData alloc] initWithDictionary:d dataName:@"body-bmi"];
                                       
                                       [fitbitJSONData saveToDataPointStore:@"BMI"];
                                   }
                                   
                               });
                           }];
}

- (void)getSleepDurationData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn
{
    NSString *path = @"1/user/-/sleep/minutesAsleep/date/today/1y.json";
    
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
                                       
                                       // Turn JSON data into basic model objects
                                       NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       //NSLog(@"count: %i", [[d objectForKey:@"activities-steps"] count]);
                                       
                                       FitbitJSONData *fitbitJSONData = [[FitbitJSONData alloc] initWithDictionary:d dataName:@"sleep-minutesAsleep"];
                                       
                                       [fitbitJSONData saveToDataPointStore:@"Sleep hours"];
                                   }
                                   
                               });
                           }];
}

@end
