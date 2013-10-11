//
//  FitbitApiDataStore.h
//  PulseBeat
//
//  Created by Omar Metwally on 10/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FitbitApiDataStore : NSObject
{
    
}

+(FitbitApiDataStore *)sharedStore;

- (void)getStepData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn;
- (void)getDistanceData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn;
- (void)getWeightData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn;
- (void)getBMIData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn;
- (void)getSleepDurationData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn;


@end
