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
    mongo::DBClientConnection conn;
    //
    try{

        //conn.connect("localhost");
            conn.connect( std::string("127.0.0.1:27017") );
    }
    catch (int exc)
    {
        NSLog(@"Exception: %d", exc);
    }
    
    NSLog (@"%@", [NSNumber numberWithInt:conn.isFailed()]);
    
}


@end
