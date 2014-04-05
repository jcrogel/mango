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
    if ([self mongoConnection])
    {
        NSLog(@"Is not null" );
    }
    else
    {
        NSLog(@"Is null" );
    }
    
}


-(void) dealloc
{
    NSLog(@"Killing Conn Mgr");
}

@end
