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
#import "CreateItemPopover.h"


@interface MangoWindowController : NSWindowController<NSOutlineViewDelegate,
                                                        MangoDataManager,
                                                        MangoPluginDelegate,
                                                        MMTabBarViewDelegate>

@property (weak) IBOutlet NSPopUpButton *dbsPopUpButton;
@property (weak) IBOutlet ConnectionBannerView *sideBar;
@property (weak) IBOutlet MMTabBarView *tabBarView;
@property (weak) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSView *popUpContainerView;
@property (strong) IBOutlet NSTreeController *collectionListTC;
@property (weak) IBOutlet NSSearchField *collectionSearchField;
@property (strong) IBOutlet NSPopover *createDBPopover;
@property (strong) IBOutlet NSPopover *createCollectionPopover;
@property (weak) IBOutlet NSOutlineView *collectionListView;

@property MangoDataManager *dataManager;
@property InfoWindowController *infoWindowController;
@property NSArray *collectionListItems;
@property MangoPluginManager *pluginManager;
@property NSAlert *popupAlert;

- (IBAction)editCollectionWasPressed:(id)sender;
- (IBAction)removeCollectionWasPressed:(id)sender;
- (IBAction)addCollectionWasPressed:(id)sender;
- (IBAction)createCollectionAction:(id)sender;

- (IBAction)createDBAction:(id)sender;

- (IBAction)showCreateDBPopoverWasPressed:(id)sender;
- (IBAction)dropDBWasPressed:(id)sender;

- (IBAction)showUsersWasPressed:(id)sender;
- (IBAction)dbInfoButtonPressed:(id)sender;
- (void) connectAndShow;
- (IBAction)dbsPopUpButtonAction:(id)sender;

-(NSString *) getSelectedDatabase;
-(NSString *) getSelectedCollectionName;

@end
