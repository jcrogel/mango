//
//  ConnectionWindow.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/3/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoConnectionManager.h"
#import <Cocoa/Cocoa.h>

@interface ConnectionWindowController : NSWindowController
@property (weak) IBOutlet NSTextField *serverTextField;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *passwordTextField;
@property (weak) IBOutlet NSButton *connectButton;
- (IBAction)connectButtonWasPressed:(id)sender;

@end

