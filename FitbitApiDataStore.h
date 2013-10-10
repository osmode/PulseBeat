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

@end
