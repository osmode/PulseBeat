//
//  Photo.h
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, strong) NSString * photoName;
@property (nonatomic, strong) NSString * photoDescription;
@property (nonatomic) float pDate;
@property (nonatomic) double orderingValue;
@property (nonatomic, strong) NSString *imageKey;

@end
