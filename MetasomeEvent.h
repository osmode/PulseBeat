//
//  MetasomeEvent.h
//  Metasome
//
//  Created by Omar Metwally on 8/26/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetasomeEvent : NSObject
{
    
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) BOOL visible;

-(id)initWithEventTitle:(NSString *)newTitle details:(NSString *)newDescription date:(NSDate *)newDate;


@end
