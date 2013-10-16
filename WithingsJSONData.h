//
//  WithingsJSONData.h
//  PulseBeat
//
//  Created by Omar Metwally on 10/9/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WithingsJSONData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *jsonData;
@property (nonatomic) int numberOfPoints;

-(id)initWithDictionary:(NSDictionary *)dict dataName:(NSString *)dn;
-(void)saveToDataPointStore:(NSString *)parameterName;

@end
