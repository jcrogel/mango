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
    
    mongo::DBClientConnection conn;
    try{
        conn.connect( [[NSString stringWithFormat:@"%@:%@", address, port ] cStringUsingEncoding:NSUTF8StringEncoding]);
        [self setMongoConnection: &conn];
    }
    catch (int exc)
    {
        NSLog(@"Exception: %d", exc);
    }
    NSLog (@"%@", [NSNumber numberWithInt:conn.isFailed()]);
    
}


@end
