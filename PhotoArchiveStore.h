//
//  PhotoArchiveStore.h
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhotoArchiveStore : NSObject
{
    NSMutableDictionary *dictionary;
}
+(PhotoArchiveStore *)sharedStore;
-(void)setImage:(UIImage *)i forKey:(NSString *)s;
-(UIImage *)imageForKey:(NSString *)s;
-(void)deleteImageForKey:(NSString *)s;

@end
