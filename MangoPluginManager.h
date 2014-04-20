//
//  MangoPluginManager.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/19/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MangoPlugin.h"

@protocol MangoPluginDelegate <NSObject>

@property MangoDataManager *dataManager;

-(void) addPluginNamed: (NSString *) name withInstance:(id<MangoPlugin>) plugin;
-(id<MangoPlugin>) createPluginInstanceWithClass: (Class) mangoPluginClass andInstanceName: (NSString *) name;

@end

@interface MangoPluginManager : NSObject

@property NSDictionary *registeredPlugins;
@property NSDictionary *activePlugins;
@property id<MangoPluginDelegate> delegate;

-(void) registerPluginName: (NSString *) name withPluginClass: (Class *) MangoPlugin;
-(id<MangoPlugin>) activePluginNamed: (NSString *) name;
-(void) setActivePlugin:(id<MangoPlugin>) plugin withName: (NSString *) name;
@end
