//
//  MangoAppDelegate.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "ConnectionWindow.h"
//#import "MangoConnectionManager.h"
#import <Cocoa/Cocoa.h>

@interface MangoAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) ConnectionWindowController *connWinController;
//@property (assign) MangoConnectionManager *connMgr;

@end
