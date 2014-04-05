//
//  MangoAppDelegate.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoWindowController.h"
#import "ConnectionWindow.h"
#import <Cocoa/Cocoa.h>

class ConnectionWindow;

@interface MangoAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) ConnectionWindowController *connWinController;
@property (nonatomic, strong) NSArray *activeWindows;

- (void) openMangoWindow: (ConnectionWindowController *)connectionWindow;

@end
