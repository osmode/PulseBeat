//
//  Photo.m
//  Metasome
//
//  Created by Omar Metwally on 9/12/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "Photo.h"


@implementation Photo

@dynamic photoName;
@dynamic photoDescription;
@dynamic pDate;
@dynamic orderingValue;
@dynamic imageKey;

-(void)awakeFromFetch
{
    [super awakeFromFetch];
    NSLog(@"awakeFromFetch called");
}
-(void)awakeFromInsert
{
    [super awakeFromInsert];
    NSLog(@"awakeFromInsert called");
}
@end
