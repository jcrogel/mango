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
    self.activeSessions = [[NSMutableArray alloc] init];
    //REMOVE BEGIN
    [self connectButtonWasPressed: self];
    [[self connectionWindow] setAutodisplay:NO];
    //REMOVE END
}

- (void) openMangoWindow
{
    MangoWindowController *mangowindow = [[MangoWindowController alloc] initWithWindowNibName:@"MangoWindow"];
    [mangowindow connectAndShow];
    [[self activeSessions] addObject: mangowindow];
}

- (IBAction)connectButtonWasPressed:(id)sender{
    [self openMangoWindow];
    NSView *sendView =  (NSView *) sender;
    if ([sender isKindOfClass:[NSView class]])
    {
        NSWindow *window = [sendView window];
        [window orderOut:self];
    }
}



@end
