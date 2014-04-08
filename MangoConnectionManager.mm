//
//  MangoConnectionManager.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoConnectionManager.h"

@implementation MangoConnectionManager


-(void) openConnection
{
    [self openConnection: nil withPort:nil andUser:nil andPassword:nil];
}

-(void) openConnection: (NSString *) address withPort: (NSString *) port andUser: (NSString *) username andPassword: (NSString *) password
{
    if (!address)
    {
        address = @"127.0.0.1";
    }
    
    if (!port)
    {
        port = @"27017";
    }
    
    if (!username)
    {
        username = @"";
    }

    if (!password)
    {
        password = @"";
    }
    
    NSValue *mongoConnPtr =  [NSValue valueWithPointer: new mongo::DBClientConnection()];
    try{
        mongo::DBClientConnection * conn = (mongo::DBClientConnection *)[mongoConnPtr pointerValue ];
        conn->connect([[NSString stringWithFormat:@"%@:%@", address, port ] cStringUsingEncoding:NSUTF8StringEncoding]);
        [self setMongoConnection: mongoConnPtr];
    }
    catch (int exc)
    {
        NSLog(@"Exception: %d", exc);
    }
}

-(NSMutableArray *) getDatabases
{

    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    mongo::BSONObj ret = [self _showDBsCMD];
    
    if (ret.hasElement("databases"))
    {
        mongo::BSONElement db_elem = ret.getField("databases");
        mongo::BSONObj dbsobj = db_elem.Obj();
        for( mongo::BSONObj::iterator i = dbsobj.begin(); i.more(); ) {
            mongo::BSONElement e = i.next();
            NSString *name = [NSString stringWithCString:e.Obj().getFieldDotted("name").valuestr() encoding:NSUTF8StringEncoding];
            [result addObject: name];
        }
    }
    
    return result;
}

-(NSArray *) getCollectionNames: (NSString *) dbname;
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *ns = [NSString stringWithFormat:@"%@.system.namespaces", dbname];
    
    mongo::DBClientConnection * conn = [self connPtr];
    
    std::auto_ptr<mongo::DBClientCursor> cursor = conn->query(
                                        [ns cStringUsingEncoding:NSUTF8StringEncoding], mongo::Query());
    
    while (cursor->more())
    {
        mongo::BSONObj p = cursor->next();
        NSString *name = [NSString stringWithUTF8String:p.getStringField("name")];
        if ([name rangeOfString:@"$"].location != NSNotFound)
        {
            continue;
        }
        [result addObject: name];
    }
    
    return result;
}

-(mongo::BSONObj) _showDBsCMD
{
    mongo::DBClientConnection * conn = [self connPtr];
    bool worked;
    mongo::BSONObj ret;
    
    // clean up old data from any previous tests
    worked = conn->runCommand( "admin", BSON("listDatabases" << 1), ret );
    if (worked) {
        return ret;
    }
    return mongo::BSONObj();
}

-(mongo::DBClientConnection *) connPtr
{
    if ([self mongoConnection])
    {
        mongo::DBClientConnection * conn = (mongo::DBClientConnection *) [[self mongoConnection] pointerValue ];
        return conn;
    }
    return nil;
}



-(void) dealloc
{
    NSLog(@"Killing Conn Mgr");
}

@end
