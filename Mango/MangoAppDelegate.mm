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
    
    //
    [[self mainWindow] close];
}

- (void) openMangoWindow
{
    if (![[self mainWindow] windowController])
    {
        MangoWindowController *mangowindow = [[MangoWindowController alloc] initWithWindowNibName:@"MangoWindow"];
        [mangowindow connectAndShow];
        [[self mainWindow ] setWindowController:mangowindow];
    }
    NSLog(@"%@",[[self mainWindow] windowController]);
    //[[[self mainWindow] windowController] showWindow:self];

}

- (IBAction)connectButtonWasPressed:(id)sender{
    [self openMangoWindow];
    NSView *sendView =  (NSView *) sender;
    NSWindow *window = [sendView window];
    [window close];
}



@end
