//
//  MetasomeEvent.m
//  Metasome
//
//  Created by Omar Metwally on 8/26/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "MetasomeEvent.h"

@implementation MetasomeEvent
@synthesize title, details, date, visible;

-(id)initWithEventTitle:(NSString *)newTitle details:(NSString *)newDescription date:(NSDate *)newDate
{
    self = [super init];
    if (self) {
        [self setTitle:newTitle];
        [self setDetails:newDescription];
        [self setDate:newDate];
        [self setVisible:YES];
    }
    return self;
}
-(NSString *)description
{
    return [self title];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:title forKey:@"eventTitle"];
    [aCoder encodeObject:details forKey:@"eventDescription"];
    [aCoder encodeObject:date forKey:@"eventDate"];
    [aCoder encodeBool:visible forKey:@"eventVisible"];

}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setTitle:[aDecoder decodeObjectForKey:@"eventTitle"]];
        [self setDetails:[aDecoder decodeObjectForKey:@"eventDescription"]];
         [self setDate:[aDecoder decodeObjectForKey:@"eventDate"]];
          [self setVisible:[aDecoder decodeBoolForKey:@"eventVisible"]];
    }
   return self;
}

@end
