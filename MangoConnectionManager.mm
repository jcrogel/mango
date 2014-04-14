//
//  MangoConnectionManager.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoConnectionManager.h"
#include "mongo/client/dbclient.h"

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
    mongo::DBClientConnection * conn = [self connPtr];
    
    std::list<std::string> dbs = conn->getDatabaseNames();
    for(std::list<std::string>::iterator iter =dbs.begin();
        iter != dbs.end(); iter++)
    {
        std::string str =  *iter;
        [result addObject:[NSString stringWithCString: str.c_str() encoding:NSUTF8StringEncoding]];
    }
        
    
    /*
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
     
     */
    
    return result;
}

-(NSArray *) getCollectionNames: (NSString *) dbname;
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    //NSString *ns = [NSString stringWithFormat:@"%@.system.namespaces", dbname];
    
    mongo::DBClientConnection * conn = [self connPtr];
    
    std::list<std::string> colNames = conn->getCollectionNames(std::string([dbname cStringUsingEncoding:NSUTF8StringEncoding]));
    
    for (std::list<std::string>::iterator i = colNames.begin(); i!=colNames.end()
         ;i++)
    {
        std::string mystr = *i;
        [result addObject: [NSString stringWithCString:mystr.c_str() encoding:NSUTF8StringEncoding]];
    }
    
    return [result sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
    
    /*
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
     */
    
    //return result;
}



/*
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
 */

-(mongo::DBClientConnection *) connPtr
{
    if ([self mongoConnection])
    {
        mongo::DBClientConnection * conn = (mongo::DBClientConnection *) [[self mongoConnection] pointerValue ];
        return conn;
    }
    return nil;
}

-(NSString *) eval: (NSString *) jscode onDB: (NSString *) dbName
{
    mongo::DBClientConnection * conn = [self connPtr];
    mongo::BSONElement ret;
    mongo::BSONObj info;
    bool success;
    @try{
        success = conn->eval([dbName cStringUsingEncoding:NSUTF8StringEncoding], [jscode cStringUsingEncoding:NSUTF8StringEncoding], info, ret);

        if (success)
        {
            NSString *retVal = [NSString stringWithCString:ret.toString().c_str() encoding:NSUTF8StringEncoding];
            return retVal;
        }
        
    }
    @catch (NSException *e)
    {
        NSLog(@"HERE %@", e);
    }

    return nil;
}

-(NSArray *) queryNameSpace: (NSString *) nameSpace withOptions: (NSDictionary *) options
{
    // TODO: Do it cleaner a la AjaxUtils
    //NSString *query = @"{}";
    NSMutableArray *result = [@[] mutableCopy];
    
    mongo::DBClientConnection * conn = [self connPtr];
    std::auto_ptr<mongo::DBClientCursor> cursor = conn->query([nameSpace cStringUsingEncoding:NSUTF8StringEncoding],
                                        mongo::Query());
    
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
    NSLog(@"Res %d", [result count]);
    return result;
    
}

-(void) dbgSel
{
    
}



@end
