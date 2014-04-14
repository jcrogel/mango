//
//  MangoConnectionManager.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MangoConnectionManager : NSObject

@property NSString *server;
@property NSString *port;
@property NSString *username;
@property NSString *db;
@property NSValue *mongoConnection;

-(void) openConnection;
-(void) openConnection: (NSString *) address withPort: (NSString *) port andUser: (NSString *) username andPassword: (NSString *) password;
-(NSString *) eval: (NSString *) jscode onDB: (NSString *) dbName;
-(NSArray *) getDatabases;
-(NSArray *) getCollectionNames: (NSString *) dbname;
-(NSArray *) queryNameSpace: (NSString *) nameSpace withOptions: (NSDictionary *) options;
-(void) dbgSel;

@end
