//
//  WithingsAPIDataStore.h
//  PulseBeat
//
//  Created by Omar Metwally on 10/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WithingsApiDataStore : NSObject
{
    
}

+(WithingsApiDataStore *)sharedStore;

- (void)getStepData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn;
- (void)getDistanceData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn;
- (void)getWeightData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn;
- (void)getBMIData:(NSString *)oauthTokenIn oauthSecretIn:oauthSecretIn;
- (void)getSleepDurationData:(NSString *)oauthTokenIn oauthSecretIn:(NSString *)oauthSecretIn;
- (void)getBloodPressureData:(NSString *)oauthTokenIn oauthSecretIn:(NSString *)oauthSecretIn userID:(NSString *)userid withCompletion:(void (^)(void))completion;


@end

