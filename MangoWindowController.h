//
//  MangoWindowController.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/4/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ITSidebar/ITSidebar.h>
#import <MMTabBarView/MMTabBarView.h>
#import <MMTabBarView/MMSafariTabStyle.h>
#import <MMTabBarView/MMCardTabStyle.h>
#import "MangoPlugin.h"
#import <MangoBrowserViewController.h>
#import "ConnectionBannerView.h"
#import "InfoWindow/InfoWindowController.h"
#import "MangoDataManager.h"
#import "MangoPluginManager.h"
#import "NSAlert+Popover.h"


@interface MangoWindowController : NSWindowController<NSOutlineViewDelegate,
                                                        MangoDataManager,
                                                        MangoPluginDelegate,
                                                        MMTabBarViewDelegate>
@property MangoDataManager *dataManager;
@property (weak) IBOutlet NSPopUpButton *dbsPopUpButton;
@property (weak) IBOutlet ConnectionBannerView *sideBar;
@property (weak) IBOutlet MMTabBarView *tabBarView;
@property (weak) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSView *popUpContainerView;
@property (strong) IBOutlet NSTreeController *collectionListTC;
@property (weak) IBOutlet NSSearchField *collectionSearchField;
@property InfoWindowController *infoWindowController;
@property NSArray *collectionListItems;
@property MangoPluginManager *pluginManager;
@property NSAlert *popupAlert;
@property (weak) IBOutlet NSOutlineView *collectionListView;

@property (strong) IBOutlet NSPopover *createDBPopover;
@property (weak) IBOutlet NSTextField *createDBInputField;

- (IBAction)createDBButtonWasPressed:(id)sender;
- (IBAction)addCollectionWasPressed:(id)sender;
- (IBAction)showCreateDBPopoverWasPressed:(id)sender;
- (IBAction)dropDBWasPressed:(id)sender;
- (IBAction)showUsersWasPressed:(id)sender;
- (IBAction)dbInfoButtonPressed:(id)sender;
- (void) connectAndShow;
- (IBAction)debugConn:(id)sender;
- (IBAction)dbsPopUpButtonAction:(id)sender;

-(NSString *) getSelectedDatabase;
-(NSString *) getSelectedCollectionName;

@end
