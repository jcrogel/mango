//
//  MangoWindowController.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/4/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoWindowController.h"

@interface MangoWindowController ()

@end

@implementation MangoWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        MangoConnectionManager *connMgr = [[MangoConnectionManager alloc] init];
        [self setConnMgr: connMgr];
    }
    return self;
}

- (void) connectAndShow
{
    NSLog(@"%@", [self connMgr]);
    [[self connMgr] openConnection];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
