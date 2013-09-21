//
//  PhotoGroup.h
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoGroup : NSObject <NSCoding>

@property (nonatomic, strong) NSString *photoGroupName;
@property (nonatomic, strong) NSString *photoGroupDescription;
@property (nonatomic, strong) NSString *imageKey;

@end
