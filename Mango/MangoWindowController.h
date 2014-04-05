//
//  MangoWindowController.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/4/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MangoConnectionManager.h"

@interface MangoWindowController : NSWindowController

@property (nonatomic, strong) MangoConnectionManager *connMgr;

- (void) connectAndShow;
- (IBAction)checkConnection:(id)sender;

@end
