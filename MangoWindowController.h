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
#import <ITSidebar/ITSidebar.h>

#import "MangoCollectionListView.h"

@interface MangoWindowController : NSWindowController

@property MangoConnectionManager *connMgr;
@property (weak) IBOutlet NSView *sourceEditor;
@property MGSFragaria *fragaria;
@property (weak) IBOutlet NSPopUpButton *dbsPopUpButton;
@property (weak) IBOutlet ITSidebar *sideBar;

@property (weak) IBOutlet MangoCollectionListView *collectionListView;

- (void) connectAndShow;
- (IBAction)debugConn:(id)sender;
- (IBAction)dbsPopUpButtonAction:(id)sender;



@end
