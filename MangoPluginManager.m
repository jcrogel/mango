//
//  MangoPluginManager.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/19/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoPluginManager.h"


@implementation MangoPluginManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setActivePlugins:@{}];
        [self setRegisteredPlugins:@{}];
    }
    return self;
}

-(void) registerPluginName: (NSString *) name withPluginClass: (Class *) MangoPlugin
{

}

-(id<MangoPlugin>) activePluginNamed:(NSString *)name
{
    return [self activePlugins][name];
}


-(void) setActivePlugin:(id<MangoPlugin>) plugin withName: (NSString *) name;
{
    NSMutableDictionary *activePlugins = [[self activePlugins] mutableCopy];
    
    activePlugins[name] = plugin;
    [self setActivePlugins: activePlugins];
}

@end
