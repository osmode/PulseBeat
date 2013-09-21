//
//  PhotoStore.h
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PhotoGroup.h"

@class Photo;
@interface PhotoStore : NSObject
{
    NSMutableArray *allPhotos;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+(PhotoStore *)sharedStore;
-(NSMutableArray *)allPhotos;
-(BOOL)saveChanges;

@end
