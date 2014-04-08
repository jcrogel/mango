//
//  MangoWindowController.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/4/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MangoConnectionManager.h"
#import <MGSFragaria/MGSFragaria.h>
#import <MGSFragaria/SMLTextView.h>

@interface MangoWindowController : NSWindowController

@property MangoConnectionManager *connMgr;
@property (weak) IBOutlet NSView *sourceEditor;
@property MGSFragaria *fragaria;

- (void) connectAndShow;
- (IBAction)debugConn:(id)sender;



@end
