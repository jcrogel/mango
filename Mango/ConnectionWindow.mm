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
    MangoAppDelegate *appDel = (__bridge MangoAppDelegate *) [[NSApplication sharedApplication] mainWindow];
    MangoConnectionManager *connMgr = [[MangoConnectionManager alloc] init];
    
    [connMgr openConnection];
    
    [self close];
}


-(void)dealloc
{
    NSLog(@"Dealloced");
}
@end

