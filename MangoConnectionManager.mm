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
    
    
    // Now format the connection string
    NSString *user = username;
    NSString *url = address;
    if ([username isEqualToString:@""])
    {
        user = @"<anonymous>";
    }
    
    if ([address isEqualToString:@"127.0.0.1"])
    {
        url = @"localhost";
    }
    
    [self setConnectionDecriptionString:[NSString stringWithFormat:@"%@@%@:%@", user, url, port]];
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
        
        // Hide System Databases
        if (str == "admin" || str == "local")
            continue;
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
    
    mongo::DBClientConnection * conn = [self connPtr];
    
    std::list<std::string> colNames = conn->getCollectionNames(std::string([dbname cStringUsingEncoding:NSUTF8StringEncoding]));
    
    for (std::list<std::string>::iterator i = colNames.begin(); i!=colNames.end()
         ;i++)
    {
        std::string mystr = *i;
        [result addObject: [NSString stringWithCString:mystr.c_str() encoding:NSUTF8StringEncoding]];
    }
    
    return [result sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
}




-(mongo::BSONObj) runCommand: (NSString *) cmd onDatabase: (NSString *) db
{
    mongo::DBClientConnection * conn = [self connPtr];
    bool worked;
    mongo::BSONObj ret;
    
    worked = conn->runCommand( [db cStringUsingEncoding:NSUTF8StringEncoding],  BSON([cmd cStringUsingEncoding:NSUTF8StringEncoding] << 1), ret );
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
    
    int limit = 0;
    if ([options objectForKey:@"limit"])
    {
        limit = [(NSNumber *) [options objectForKey:@"limit"] intValue];
    }
    NSMutableArray *result = [@[] mutableCopy];
    
    mongo::DBClientConnection * conn = [self connPtr];
    std::auto_ptr<mongo::DBClientCursor> cursor = conn->query([nameSpace cStringUsingEncoding:NSUTF8StringEncoding], mongo::Query(), limit);

    
    while (cursor->more())
    {
        mongo::BSONObj p = cursor->next();
        NSError *e;
        NSString *json = [NSString stringWithCString: p.jsonString().c_str() encoding:NSUTF8StringEncoding ];
        id jsonObj = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                        options:0
                                          error:&e];
        if (e)
        {
            
            NSLog(@"%@", e );
            NSLog(@"%@", json);
            return @[];
        }
        
        if (jsonObj)
        {
            [result addObject: jsonObj];
        }
    }
    
    // TODO: Do propper limit by
    //NSUInteger min = MIN([result count], 10);
    //return [result subarrayWithRange:NSMakeRange(0, min)];
    return result;
    
}

-(void) dbgSel
{
    
}

- (id) getObjectID: (NSString *) oid onDB: (NSString *) dbname;
{
    //mongo::OID oidObj = mongo::OID([oid cStringUsingEncoding:NSUTF8StringEncoding]);
    return nil;
}

-(id) stringToJSON: (NSString *) json
{
    NSError *e;
    if (!json)
        return nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:0
                                                   error:&e];
    if (!e)
        return jsonObj;
    return nil;
}

-(BOOL) createDBNamed: (NSString *) dbname
{
    mongo::DBClientConnection * conn = [self connPtr];
    bool worked;
    mongo::BSONObj ret;
    
    NSString *ns = [NSString stringWithFormat:@"%@.__mango__", dbname];
    
    worked = conn->createCollection( [ns cStringUsingEncoding:NSUTF8StringEncoding]);
    if (worked) {
        worked = conn->dropCollection ([ns cStringUsingEncoding:NSUTF8StringEncoding]);
        if (worked)
            return YES;
    }
    return NO;
}


-(BOOL) createCollectionNamed: (NSString *)collection onDB: (NSString *) dbname
{
    mongo::DBClientConnection * conn = [self connPtr];
    bool worked;
    mongo::BSONObj ret;
    
    NSString *ns = [NSString stringWithFormat:@"%@.%@",dbname, collection];
    
    worked = conn->createCollection( [ns cStringUsingEncoding:NSUTF8StringEncoding]);
    if (worked) {
        return YES;
    }
    return NO;
}


-(BOOL) dropCollectionNamed: (NSString *)collection onDB: (NSString *) dbname;
{
    
    mongo::DBClientConnection * conn = [self connPtr];
    bool worked;
    mongo::BSONObj ret;
    
    NSString *ns = [NSString stringWithFormat:@"%@.%@",dbname, collection];
    
    worked = conn->dropCollection( [ns cStringUsingEncoding:NSUTF8StringEncoding]);
    if (worked) {
        return YES;
    }
    return NO;
}

-(id) getDBStats: (NSString *) dbname
{
    mongo::BSONObj result = [self runCommand:@"dbStats" onDatabase:dbname];
    return [self stringToJSON: [NSString stringWithCString: result.toString().c_str() encoding:NSUTF8StringEncoding]];
}

-(BOOL) dropDB: (NSString *) dbname
{
    mongo::BSONObj result = [self runCommand:@"dropDatabase" onDatabase:dbname];
    mongo::BSONElement isOk = result.getField("ok");
    if (isOk.isNumber())
    {
        if (isOk.numberInt()!=0.0)
            return YES;
    }
    return NO;
}

-(id) getServerStatus
{
    mongo::BSONObj result = [self runCommand:@"serverStatus" onDatabase:@"admin"];
    return [self stringToJSON: [NSString stringWithCString: result.jsonString().c_str() encoding:NSUTF8StringEncoding]];
}

-(id) getCollectionInfo: (NSString *) nspace
{
    mongo::BSONObj result = [self runCommand:@"serverStatus" onDatabase:@"admin"];
    return [self stringToJSON:[NSString stringWithCString: result.toString().c_str() encoding:NSUTF8StringEncoding]];
}

@end
