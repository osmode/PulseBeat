//
//  PhotoGroupStore.h
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoGroup;
@interface PhotoGroupStore : NSObject
{
}

@property (nonatomic, copy) NSMutableArray *photoGroupArray;

+(PhotoGroupStore *)sharedStore;
-(void)removePhotoGroup:(PhotoGroup *)g;
-(void)moveItemAtIndex:(int)from toIndex:(int)to;
-(NSString *)itemArchivePath;
-(BOOL)saveChanges;
-(NSMutableArray *)photoGroupArray;
-(void)addPhotoGroup:(PhotoGroup *)photoGroup;


@end
