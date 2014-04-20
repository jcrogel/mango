//
//  MangoWindowController.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/4/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoWindowController.h"
#import <INAppStoreWindow/INAppStoreWindow.h>

@interface MangoWindowController ()

@end

@implementation MangoWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        MangoDataManager *dataManager = [[MangoDataManager alloc] init];
        [dataManager setDelegate:self];
        [self setDataManager:dataManager];
        [self setPluginManager:[[MangoPluginManager alloc] init]];
        [[self pluginManager] setDelegate: self];
    }
    return self;
}

#pragma mark - Server Actions

- (IBAction)serverInfoButtonPressed:(id)sender {
    //[[self connMgr] getServerStatus];
}

#pragma mark - Database Actions

- (IBAction)dbInfoButtonPressed:(id)sender {
    //[[self connMgr] getDBStats: [self getSelectedDatabase]];
    //InfoWindowController *mangowindow = [[InfoWindowController alloc] initWithWindowNibName:@"InfoWindow"];
    //[mangowindow showWindow: self];
    
}

- (IBAction)dbsPopUpButtonAction:(id)sender
{
    [[self collectionSearchField] setStringValue:@""];
    [[self dataManager] fetchCollectionNamesForDB: [self getSelectedDatabase]];
    [[self dataManager] processCollectionsWithFilter:[[self collectionSearchField] stringValue]];
}

#pragma mark - Collection Actions

- (IBAction)collectionInfoButtonPressed:(id)sender{
    //[[self connMgr] getCollectionInfo: [NSString stringWithFormat:@"%@.%@", [self getSelectedDatabase], [self getSelectedCollectionName]]];
}


- (void)controlTextDidChange:(NSNotification *)aNotification {
    if ([[aNotification object] isKindOfClass: [NSSearchField class ]])
    {
        [[self dataManager] processCollectionsWithFilter:[[self collectionSearchField] stringValue]];
    }
}


#pragma mark - Document UI Actions

-(void) outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSString *selectedCollection = [self getSelectedCollectionName];
    NSString *selectedDB = [self getSelectedDatabase];
    NSTabViewItem *selectedItem = [[self tabView] selectedTabViewItem];
    NSString *tabName = [selectedItem label];
    
    id<MangoPlugin> plugin = [[self pluginManager] activePluginNamed: tabName];
    
    [plugin refreshDataFromDB:selectedDB withCollection:selectedCollection andDataManager:[self dataManager]];
}

- (void) connectAndShow
{
    [[[self dataManager] ConnectionManager ] openConnection];
    [self window];
}

- (IBAction)debugConn:(id)sender {
}

#pragma mark - UI Setup

-(void) setupDBsPopUpButton
{
    NSArray * dbs = [[[self dataManager] ConnectionManager] getDatabases];
    [[self dbsPopUpButton] removeAllItems];
    [[self dbsPopUpButton] addItemsWithTitles:dbs];
}

-(void) setupSideBar
{
    [[self sideBar] setConnectionURL:@"<anonymous>@localhost"];
}

-(void) setupTabs
{
    [[self tabBarView] setTabView: [self tabView]];
    MMSafariTabStyle *style = [[MMSafariTabStyle alloc] init];
    [[self tabBarView] setStyle:style];
    MangoBrowserViewController *tabContent = [[MangoBrowserViewController alloc] initWithNibName:@"MangoBrowserViewController" bundle:[NSBundle bundleForClass:[self class]]];
    NSTabViewItem *currentTab = [[self tabView] tabViewItemAtIndex:0];
    [[tabContent view] setFrame:[[currentTab view]frame]];
    [[currentTab view] addSubview:[tabContent view]];
    [[self pluginManager] setActivePlugin:tabContent withName: currentTab.label];
}

-(void) setupWindow
{
    INAppStoreWindow *window = (INAppStoreWindow *) [self window];
	window.trafficLightButtonsLeftMargin = 7.0;
	window.fullScreenButtonRightMargin = 7.0;
	window.centerFullScreenButton = YES;
	window.titleBarHeight = 60.0;
    window.verticalTrafficLightButtons = YES;
    
	// set checkboxes
    
	window.showsTitle = NO;
	[self setupCloseButton: window];
	[self setupMinimizeButton: window];
	[self setupZoomButton: window];
    
    NSRect rect = [[self popUpContainerView] frame];
    rect.origin.x += 70;
    [[self popUpContainerView] setFrame:rect];
    [window.titleBarView addSubview:[self popUpContainerView]];
}

- (void)setupCloseButton:(INAppStoreWindow *) window
{
	INWindowButton *closeButton = [INWindowButton windowButtonWithSize:NSMakeSize(14, 16) groupIdentifier:nil];
	closeButton.activeImage = [NSImage imageNamed:@"close-active-color"];
	closeButton.activeNotKeyWindowImage = [NSImage imageNamed:@"close-activenokey-color"];
	closeButton.inactiveImage = [NSImage imageNamed:@"close-inactive-disabled-color"];
	closeButton.pressedImage = [NSImage imageNamed:@"close-pd-color"];
	closeButton.rolloverImage = [NSImage imageNamed:@"close-rollover-color"];
	window.closeButton = closeButton;
}

- (void)setupMinimizeButton:(INAppStoreWindow *) window
{
	INWindowButton *button = [INWindowButton windowButtonWithSize:NSMakeSize(14, 16) groupIdentifier:nil];
	button.activeImage = [NSImage imageNamed:@"minimize-active-color"];
	button.activeNotKeyWindowImage = [NSImage imageNamed:@"minimize-activenokey-color"];
	button.inactiveImage = [NSImage imageNamed:@"minimize-inactive-disabled-color"];
	button.pressedImage = [NSImage imageNamed:@"minimize-pd-color"];
	button.rolloverImage = [NSImage imageNamed:@"minimize-rollover-color"];
	window.minimizeButton = button;
}

- (void)setupZoomButton:(INAppStoreWindow *) window
{
	INWindowButton *button = [INWindowButton windowButtonWithSize:NSMakeSize(14, 16) groupIdentifier:nil];
	button.activeImage = [NSImage imageNamed:@"zoom-active-color"];
	button.activeNotKeyWindowImage = [NSImage imageNamed:@"zoom-activenokey-color"];
	button.inactiveImage = [NSImage imageNamed:@"zoom-inactive-disabled-color"];
	button.pressedImage = [NSImage imageNamed:@"zoom-pd-color"];
	button.rolloverImage = [NSImage imageNamed:@"zoom-rollover-color"];
	window.zoomButton = button;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self setupWindow];
    [self setupDBsPopUpButton];
    [self setupSideBar];
    [self setupTabs];
}

#pragma mark - Collection List

- (void)setCollectionList:(NSArray *)cl
{
   
}

# pragma mark - Utility functions

-(NSString *) getSelectedCollectionName
{
    NSTreeNode *selectedNode = [[[self collectionListTC] selectedNodes] objectAtIndex:0];
    NSDictionary *selectedNodeObj = [selectedNode representedObject];
    NSString *selectedCollection = selectedNodeObj[@"name"];
    return selectedCollection;
}

-(NSString *) getSelectedDatabase
{
    return [[[self dbsPopUpButton] selectedItem]  title];
}

- (IBAction)runCommand:(id)sender {
    NSString *dbName = [[[self dbsPopUpButton] selectedItem]  title];
    NSLog(@"%@", dbName);
}

# pragma mark - DataManager callbacks

-(void) setCollectionData: (NSArray *)data
{
    [self setCollectionListItems: data];
}

# pragma mark - MangoPluginDelegate

-(void) addPluginNamed: (NSString *) name withInstance:(id<MangoPlugin>) plugin
{

    NSTabViewItem *newTab = [[NSTabViewItem alloc] init];
    [newTab setLabel:name];
    [[self tabView] addTabViewItem:newTab];
    [[self tabView] selectTabViewItem:newTab];
    if ([plugin isKindOfClass:[NSViewController class]])
    {
        NSViewController *pVC = (NSViewController *)plugin;
        [[pVC view] setFrame:[[newTab view]frame]];
        [[newTab view] addSubview:[pVC view]];
    }
    [[self tabBarView] setNeedsUpdate:YES];

    [[self pluginManager] setActivePlugin:plugin withName: name];
}

-(id<MangoPlugin>) createPluginInstanceWithClass:(Class)cls andInstanceName:(NSString *)name
{
    
    id<MangoPlugin> newPlugin = [[cls alloc] init];
    return newPlugin;
}

@end
