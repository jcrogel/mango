//
//  MangoConnectionManager.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MangoConnectionManager : NSObject

@property NSValue *mongoConnection;
@property NSString *connectionDecriptionString;

-(void) openConnection;
-(void) openConnection: (NSString *) address withPort: (NSString *) port andUser: (NSString *) username andPassword: (NSString *) password;
-(NSString *) eval: (NSString *) jscode onDB: (NSString *) dbName;
-(NSArray *) getDatabases;
-(NSArray *) getCollectionNames: (NSString *) dbname;
-(NSArray *) queryNameSpace: (NSString *) nameSpace withOptions: (NSDictionary *) options;
-(void) dbgSel;

-(BOOL) createDBNamed: (NSString *) dbname;
-(BOOL) createCollectionNamed: (NSString *)collection onDB: (NSString *) dbname;
-(BOOL) dropCollectionNamed: (NSString *)collection onDB: (NSString *) dbname;
-(id) getDBStats: (NSString *) dbname;
-(id) getServerStatus;
-(BOOL) dropDB: (NSString *) dbname;
-(id) getCollectionInfo: (NSString *) nspace;

- (id) getObjectID: (NSString *) oid onDB: (NSString *) dbname;

@end
