//
//  MangoConnectionManager.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "mongo/client/dbclient.h"


@interface MangoConnectionManager : NSObject

@property (assign) NSString *server;
@property (assign) NSString *port;
@property (assign) NSString *username;
@property (assign) NSString *db;
@property (assign) mongo::DBClientConnection *mongoConnection;

-(void) openConnection;
-(void) openConnection: (NSString *) address withPort: (NSString *) port andUser: (NSString *) username andPassword: (NSString *) password;


@end
