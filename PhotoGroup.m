//
//  PhotoGroup.m
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "PhotoGroup.h"

@implementation PhotoGroup
@synthesize photoGroupName, photoGroupDescription, imageKey;

-(id)initWithPhotoGroupName:(NSString *)name photoGroupDescription:(NSString *)newDescription image:(UIImage *)newImage
{
    self = [super init];
    if (self) {
        [self setPhotoGroupName:name];
        [self setPhotoGroupDescription:photoGroupDescription];
        //[self setFirstImage:newImage];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:photoGroupName forKey:@"photoGroupName"];
    [aCoder encodeObject:photoGroupDescription forKey:@"photoGroupDescription"];

}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setPhotoGroupName:[aDecoder decodeObjectForKey:@"photoGroupName"]];
        [self setPhotoGroupDescription:@"photoGroupDescription"];
    }
    return self;
}

-(NSString *)description
{
    return [self photoGroupName];
}

@end
