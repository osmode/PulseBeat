//
//  OptionsTableView.m
//  Metasome
//
//  Created by Omar Metwally on 9/15/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import "OptionsTableView.h"
#import "OptionsTableViewDataSource.h"

@implementation OptionsTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        OptionsTableViewDataSource *dataSource = [[OptionsTableViewDataSource alloc] init];
        
        [self setDataSource:dataSource];
        
    }
    return self;
}


@end
