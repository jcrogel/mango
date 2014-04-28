//
//  CollectionDataManager.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/17/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

// Handles all data, formatting and connections to the db

#import <Foundation/Foundation.h>
#import "MangoConnectionManager.h"

@protocol MangoDataManager <NSObject>

-(void) setCollectionData: (NSArray *)data;

@end

@interface MangoDataManager : NSObject

@property MangoConnectionManager *ConnectionManager;
@property NSArray *CollectionData;

@property id<MangoDataManager> delegate;


- (void) fetchCollectionNamesForDB: (NSString *) DBName;
- (void) processCollectionsWithFilter: (NSString *) filterBy;
- (void) getObjectID: (NSString *) oid onDB: (NSString *) dbname;

-(NSDictionary *) documentToMango: (NSDictionary *) item;
-(NSArray *) convertMultipleJSONDocumentsToMango: (NSArray *) data;
-(NSArray *) convertJSONDictionaryToMango: (NSDictionary *) data;
-(NSDictionary *) convertJSONToMangoFromValue: (id) value withName: (NSString *) name;

@end
