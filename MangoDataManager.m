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
                id element = fname_elements[i];
                if ([ptr isKindOfClass:[NSDictionary class]])
                {
                    [ptr setObject:@"" forKey:element];
                }
                else
                {
                    NSLog(@"Malformed object Skipped: %@ from %@",element, filteredCollections);
                }
                
                
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
        
    };
    
    NSMutableArray *rootArray = [[self crawlCollectionDict: aux] mutableCopy];
    
    [rootArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *o1 = obj1[@"name"];
        NSString *o2 = obj2[@"name"];
        
        return [o1 localizedCaseInsensitiveCompare:o2];
    }];
    
    [[self delegate] setCollectionData:rootArray];
}

-(NSArray *) crawlCollectionDict: (NSDictionary *) dict
{
    NSMutableArray *result = [NSMutableArray new];
    NSArray *descendants = [dict allKeys];
    for (NSString *key in descendants)
    {
        if ([key isEqualToString:@"system"])
            continue;
        
        id obj = [dict objectForKey:key];
        NSMutableDictionary *item = [NSMutableDictionary new];
        item[@"name"] = key;
        
        if ([obj isKindOfClass:[NSString class]])
        {
            item[@"children"] = @[];
        }
        else
        {
            // IS GridFS?
            
            id  chunkKey = [obj objectForKey:@"chunks"];
            id filesKey = [obj objectForKey:@"files"];
            if (filesKey && chunkKey && [obj count]==2)
            {
                item[@"GridFS"] = [NSNumber numberWithBool:YES];
            }
            else
            {
                item[@"children"] = [self crawlCollectionDict:obj];
            }
            
        }
        
        [result addObject: item];
    }
    
    return result;
    
}


- (void) getObjectID: (NSString *) oid onDB: (NSString *) dbname;
{
    [[self ConnectionManager] getObjectID: oid onDB:dbname];
}

#pragma mark - JSON to Mango

-(NSArray *) convertMultipleJSONDocumentsToMango: (NSArray *) data
{
    NSMutableArray *retval = [@[] mutableCopy];
    for (id item in data)
    {
        if ([item isKindOfClass:[NSDictionary class]])
        {
            [retval addObject:[self documentToMango:item]];
        }
    }
    return retval;
}

-(NSDictionary *) documentToMango: (NSDictionary *) item
{
    NSMutableDictionary *reformattedItem = [@{} mutableCopy];
    reformattedItem[@"Type"] = @"Dictionary";
    
    NSString *title = @"";
    id oid = item[@"_id"];
    if (oid && [oid isKindOfClass: [NSDictionary class]] && [oid valueForKey:@"$oid"])
    {
        title = @"Document";
        reformattedItem[@"Type"] = @"ObjectID";
        reformattedItem[@"Value"] = [NSString stringWithFormat:@"%@", oid[@"$oid"]];
    }
    
    reformattedItem[@"Name"] = title;
    // remove _id from view
    NSMutableDictionary *cleanedItem = [item mutableCopy];
    [cleanedItem removeObjectForKey:@"_id"];
    NSArray *children = [self convertJSONDictionaryToMango: cleanedItem];
    reformattedItem[@"Children"] = children;
    
    return reformattedItem;
}

-(NSDictionary *) convertJSONToMangoFromValue: (id) value withName: (NSString *) name
{
    NSMutableDictionary *reformattedItem = [@{} mutableCopy];
    reformattedItem[@"Name"] = name;
    reformattedItem[@"Editable"] = [NSNumber numberWithBool: YES];
    if ([value isKindOfClass:[NSDictionary class]])
    {
        
        NSMutableDictionary *cleanedItem = [value mutableCopy];
        
        reformattedItem[@"Type"] = @"Dictionary";
        reformattedItem[@"Value"] = [NSString stringWithFormat:@"{ %@ }", [NSNumber numberWithLong:[value count]]];
        
        if ([cleanedItem valueForKey:@"$oid"])
        {
            id rOID = [cleanedItem valueForKey:@"$oid"];
            reformattedItem[@"Type"] = @"ObjectID";
            reformattedItem[@"Value"] = [NSString stringWithFormat:@"%@", rOID];
            reformattedItem[@"Links"] = [rOID copy];
            reformattedItem[@"Editable"] = [NSNumber numberWithBool: NO];
            [cleanedItem removeObjectForKey:@"$oid"];
        }
        
        if ([cleanedItem valueForKey:@"$date"])
        {
            id date = [cleanedItem valueForKey:@"$date"];
            if([date isKindOfClass:[NSString class]])
            {
                reformattedItem[@"Type"] = @"Date";
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS.SSSZ"];
                
                NSDate *myDate = [dateFormatter dateFromString:date];
                
                NSDateFormatter *anotherDateFormatter = [[NSDateFormatter alloc] init];
                [anotherDateFormatter setDateStyle:NSDateFormatterLongStyle];
                [anotherDateFormatter setTimeStyle:NSDateFormatterShortStyle];
                
                reformattedItem[@"Value"] = [anotherDateFormatter stringFromDate:myDate];
                
                [cleanedItem removeObjectForKey:@"$date"];
            }
            
        }
        
        NSArray *children = [self convertJSONDictionaryToMango: cleanedItem];
        reformattedItem[@"Children"] = children;
        
        
    }
    else if ([value isKindOfClass:[NSArray class]])
    {
        NSMutableArray *reformattedChildren = [@[] mutableCopy];
        for (int i=0; i<[value count]; i++)
        {
            NSDictionary *reformattedChild = [self convertJSONToMangoFromValue:[value objectAtIndex:i] withName:[NSString stringWithFormat:@"%d", i ]];
            [reformattedChildren addObject:reformattedChild];
        }
        reformattedItem[@"Children"] = reformattedChildren;
        reformattedItem[@"Value"] = [NSString stringWithFormat:@"[ %@ ]", [NSNumber numberWithLong:[value count]]];
        
        reformattedItem[@"Type"] = @"Array";
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        reformattedItem[@"Value"] = value;
        reformattedItem[@"Type"] = @"String";
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        reformattedItem[@"Value"] = value;
        
        if ([value isKindOfClass:[[NSNumber numberWithBool: YES] class]])
        {
            reformattedItem[@"Type"] = @"Bool";
        }
        else
        {
            reformattedItem[@"Type"] = @"Number";
        }
    }
    else if([value isKindOfClass:[NSNull class]])
    {
        reformattedItem[@"Value"] = @"";
        reformattedItem[@"Type"] = @"Null";
    }
    else
    {
        
        NSLog(@"Unknown %@ %@", name ,[value class]);
    }
    return reformattedItem;
}

-(NSArray *) convertJSONDictionaryToMango: (NSDictionary *) data
{
    NSMutableArray *retval = [@[] mutableCopy];
    for (id key in [data keyEnumerator])
    {
        id value = data[key];
        NSDictionary *reformattedItem = [self convertJSONToMangoFromValue:value withName:key];
        [retval addObject:reformattedItem];
    }
    return retval;
}

#pragma mark - Mango to JSON

-(id)mangoToJSON: (id) d
{
    // We assume all are objects of kind dict
    NSDictionary *data = (NSDictionary *)d;
    if (![data isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"Verify data %@", data);
        return nil;
    }

    NSString *type = [data valueForKey:@"Type"];
    id value = [data valueForKey:@"Value"];
    id retval;
    if ([type isEqualToString:@"Dictionary"] || [type isEqualToString:@"ObjectID"])
    {
        NSMutableDictionary *_retVal = [@{} mutableCopy];
        for (NSDictionary *child in [data valueForKey:@"Children"])
        {
            id _jsonChild = [self mangoToJSON:child];
            [_retVal setValue:_jsonChild forKey:[child valueForKey:@"Name"]];
        }
        return _retVal;
    }
    
    if ([type isEqualToString:@"Array"])
    {
        NSMutableArray *_retVal = [@[] mutableCopy];
        for (NSDictionary *child in [data valueForKey:@"Children"])
        {
            id _jsonChild = [self mangoToJSON:child];
            [_retVal addObject: _jsonChild];
        }
        return _retVal;
    }
    
    else
    {
        // TODO: Do extra encapsulation for numbers or bools
        return value;
    }
    
    return retval;
}


@end
