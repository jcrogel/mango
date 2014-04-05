//
//  MangoAppDelegate.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoAppDelegate.h"

@implementation MangoAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [[self window] setLevel:kCGFloatingWindowLevel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[self window] animator] setAlphaValue:0.0];
        [self setConnWinController:[[ConnectionWindowController alloc] initWithWindowNibName:@"ConnectionWindow"]];
        [[self connWinController] loadWindow];

    });
}

- (void) openMangoWindow: (ConnectionWindowController *)connectionWindow
{
    MangoWindowController *mangowindow = [[MangoWindowController alloc] initWithWindowNibName:@"MangoWindow"];
    [mangowindow connectAndShow];
//    [connMgr openConnection];

}

@end
