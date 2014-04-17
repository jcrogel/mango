//
//  MangoWindowController.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/4/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MangoConnectionManager.h"
#import <ITSidebar/ITSidebar.h>
#import <MMTabBarView/MMTabBarView.h>
#import <MMTabBarView/MMSafariTabStyle.h>
#import <MMTabBarView/MMCardTabStyle.h>
#import "MangoPlugin.h"
#import <MangoBrowserView.h>
#import "ConnectionBannerView.h"
#import "InfoWindow/InfoWindowController.h"

@interface MangoWindowController : NSWindowController<NSOutlineViewDelegate>

@property MangoConnectionManager *connMgr;
@property (weak) IBOutlet NSPopUpButton *dbsPopUpButton;
@property (weak) IBOutlet ConnectionBannerView *sideBar;
@property (weak) IBOutlet MMTabBarView *tabBarView;
@property (weak) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSView *popUpContainerView;
@property (strong) IBOutlet NSTreeController *collectionListTC;
@property NSArray *collectionListItems;
@property NSDictionary *activePlugins;
- (IBAction)dbInfoButtonPressed:(id)sender;

- (IBAction)runCommand:(id)sender;
- (void) connectAndShow;
- (IBAction)debugConn:(id)sender;
- (IBAction)dbsPopUpButtonAction:(id)sender;



@end
