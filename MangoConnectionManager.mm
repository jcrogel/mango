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

-(void) dbgConn
{
    //mongo::Query([query cStringUsingEncoding: NSUTF8StringEncoding]);
    //std::auto_ptr<mongo::DBClientCursor> cursor = conn->query("admin",mongo::Query("{ listDatabases : 1 }"));
    
    /*while (cursor->more())
    {
        mongo::BSONObj p = cursor->next();
        NSLog(@"%s",p.getStringField("name"));
    }*/
    
    mongo::BSONObj ret = [self showDBs];
    
    if (ret.hasElement("databases"))
    {
        mongo::BSONElement db_elem = ret.getField("databases");
        mongo::BSONObj dbsobj = db_elem.Obj();
        for( mongo::BSONObj::iterator i = dbsobj.begin(); i.more(); ) {
            mongo::BSONElement e = i.next();
            
            NSLog(@"%s", e.Obj().getFieldDotted("name").toString().c_str());
        }
    }
}

-(mongo::BSONObj) showDBs
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
