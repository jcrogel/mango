//
//  MangoAppDelegate.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoWindowController.h"
#import <Cocoa/Cocoa.h>

class ConnectionWindow;

@interface MangoAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *mainWindow;
@property (assign) IBOutlet NSWindow *connectionWindow;
@property (nonatomic, strong) NSMutableArray *activeWindows;

- (void) openMangoWindow;


- (IBAction)connectButtonWasPressed:(id)sender;

@end
