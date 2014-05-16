//
//  MangoPlugin.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/13/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MangoDataManager;

@protocol MangoPlugin <NSObject>

@property BOOL isGridFS;
-(void) refreshDataFromDB: (NSString *) db withCollection: (NSString *) col andDataManager: (MangoDataManager *) mgr;

@end
