//
//  ConnectionWindow.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "ConnectionWindow.h"

class MangoAppDelegate;

@implementation ConnectionWindowController : NSWindowController


- (IBAction)connectButtonWasPressed:(id)sender {
    id appDel = [[NSApplication sharedApplication] delegate];
    
    SEL setConnMgrSel = sel_registerName("openMangoWindow:");
    if ([appDel respondsToSelector:setConnMgrSel])
    {
        [appDel performSelector:setConnMgrSel withObject:self];
    }

    [self close];
}


-(void)dealloc
{
    NSLog(@"Dealloced");
}
@end

