//
//  MangoPlugin.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/13/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MangoConnectionManager;

@protocol MangoPlugin <NSObject>

-(void) refreshDataFromDB: (NSString *) db withCollection: (NSString *) col andConnMgr: (MangoConnectionManager *) mgr;

@end
