//
//  MetasomeParameterStore.h
//  Metasome
//
//  Created by Omar Metwally on 8/19/13.
//  Copyright (c) 2013 Logisome. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MetasomeParameter;

typedef enum {
    SectionVitals,
    SectionMind,
    SectionBody
} SectionType;

@interface MetasomeParameterStore : NSObject
{
    
}
@property (nonatomic, copy) NSMutableArray *sections;
@property (nonatomic, copy) NSMutableArray *heartList, *lungList, *diabetesList, *customList, *userEmail;
@property (nonatomic, weak) NSMutableArray *currentList;
@property (nonatomic, copy) NSMutableArray *parameterArray;

//used to create sections; populated with dictionaries,
//a dictionary for each section

+ (MetasomeParameterStore *)sharedStore;
-(void)addParameter:(MetasomeParameter *)p;
-(void)removeItem:(MetasomeParameter *)p;
-(void)moveItemAtIndex:(int)from toIndex:(int)to inSection:(int)sec;
-(void)loadDefaultParameters;
-(NSString *)itemArchivePath;
-(BOOL)saveChanges;


@end
