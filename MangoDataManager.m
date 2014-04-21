//
//  CollectionDataManager.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/17/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoDataManager.h"

@implementation MangoDataManager

-(id) init
{
    self = [super init];
    if (self)
    {
        MangoConnectionManager *connMgr = [[MangoConnectionManager alloc] init];
        [self setConnectionManager: connMgr];
    }
    return self;
}

-(void) fetchCollectionNamesForDB: (NSString *) DBName
{
    NSArray *collections = [[self ConnectionManager] getCollectionNames: DBName];
    [self setCollectionData:collections];
}

- (void) processCollectionsWithFilter: (NSString *) filterBy
{
    NSMutableArray *filteredCollections = [[self CollectionData] mutableCopy];
    if ([[filterBy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
    {
        NSString *predicateFormat = [NSString stringWithFormat:@"SELF contains[c] '%@'", filterBy];
        NSPredicate *sPredicate =
        [NSPredicate predicateWithFormat:predicateFormat];
        [filteredCollections filterUsingPredicate:sPredicate];
    }

    NSMutableDictionary *aux = [NSMutableDictionary new];
    
    NSString *rootTitle;
    for (NSString *cl_fullname in filteredCollections)
    {
        NSArray *fname_elements = [cl_fullname componentsSeparatedByString:@"."];
        NSUInteger length = [fname_elements count];
        NSMutableDictionary *ptr = aux;
        if (!rootTitle)
        {
            rootTitle = fname_elements[0];
        }
        
        for (int i=1; i<length; i++)
        {
            if (i == length-1)
            {
                // Last item
                [ptr setObject:@"" forKey:fname_elements[i]];
            }else
            {
                NSMutableDictionary *column = [ptr valueForKey:fname_elements[i]];
                if (column)
                {
                    ptr = column;
                }
                else
                {
                    NSMutableDictionary *value = [@{} mutableCopy];
                    [ptr setObject:value forKey:fname_elements[i]];
                    ptr = value;
                }
            }
        }
    }
    
    NSMutableArray *rootArray = [NSMutableArray new];
    
    /// THIS NEEDS TO SUPPORT CHILDREN
    for (id rootKey in aux)
    {
        id value = [aux valueForKey:rootKey];
        
        if ([value isKindOfClass:[NSString class]])
        {
            NSMutableDictionary *item = [NSMutableDictionary new];
            item[@"name"] = rootKey;
            item[@"children"] = @[];
            [rootArray addObject:item];
        }
        else
        {
            // Forward Pointer
        }
    }
    
    [rootArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *o1 = obj1[@"name"];
        NSString *o2 = obj2[@"name"];
        
        return [o1 localizedCaseInsensitiveCompare:o2];
    }];
    
    [[self delegate] setCollectionData:rootArray];
}


- (void) getObjectID: (NSString *) oid
{
    [[self ConnectionManager] getObjectID: oid];
}

@end
