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
        [window setDelegate:self];
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
    InfoWindowController *mangowindow = [[InfoWindowController alloc] initWithWindowNibName:@"InfoWindow"];

    [[mangowindow window] setTitle:[[[self dataManager] ConnectionManager] connectionDecriptionString]];
    [mangowindow setDataManager: [self dataManager]];
    [self setInfoWindowController:mangowindow];
    [mangowindow showWindow: self];
    [mangowindow getServerInfo];
}


#pragma mark - Database Actions

- (IBAction)removeCollectionWasPressed:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Do you really want to drop this collection?"
                                     defaultButton:@"Drop Collection"
                                   alternateButton:@"Learn more"
                                       otherButton:@"Cancel"
                         informativeTextWithFormat:@"Deleting this item will erase all associated data in the collection. This action cannot be undone."];
    
    [self setPopupAlert:alert];
    NSButton *sButton = (NSButton *) sender;
    [alert runAsPopoverForView:sButton withCompletionBlock:^(NSInteger result) {
		// handle result
        if (result==NSAlertFirstButtonReturn)
        {
            BOOL result = [[[self dataManager] ConnectionManager] dropCollectionNamed:[self getSelectedCollectionName] onDB: (NSString *)[self getSelectedDatabase]];
            if(result)
            {
                [self refrechCollectionOutline];
            }
            else
            {
                NSAlert *alert2 = [[NSAlert alloc] init];
                [alert2 setMessageText: [NSString stringWithFormat:@"Unable to drop collection %@", [self getSelectedCollectionName]]];
                [alert2 runModal];
                
            }
        }
	}];
}

- (IBAction)editCollectionWasPressed:(id)sender {
    [self showPopOver:[self renameCollectionPopover] withSender:sender];
}

- (IBAction)addCollectionWasPressed:(id)sender {
    [self showPopOver:[self createCollectionPopover] withSender:sender];
}

-(void) showPopOver: ( NSPopover *) po withSender: (id) sender
{
    if ([po isShown])
    {
        [po close];
    }
    else
    {
        [po showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    }
}

- (IBAction)createCollectionAction:(id)sender {

    CreateItemPopover *pvc = (CreateItemPopover *) [[self createCollectionPopover] contentViewController];
    NSString *newDBName = [[pvc inputTextField] stringValue];
    if (newDBName  && [newDBName length]>0)
    {
        newDBName = [newDBName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        /*if([[[self dataManager] ConnectionManager] createCollectionNamed:newDBName onDB:[self getSelectedDatabase]])
        {
         
        }*/
        [self refrechCollectionOutline];
        [[pvc inputTextField] setStringValue:@""];
        [[self createCollectionPopover] close];
        
    }
}


- (IBAction)renameDBWasPressed:(id)sender {
    CreateItemPopover *pvc = (CreateItemPopover *) [[self renameCollectionPopover] contentViewController];
    NSString *newCollName = [[pvc inputTextField] stringValue];
    if (newCollName  && [newCollName length]>0)
    {
        newCollName = [newCollName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([[[self dataManager] ConnectionManager] createCollectionNamed:newCollName onDB:[self getSelectedDatabase]])
        {
            //[self setupDBsPopUpButton];
            [self refrechCollectionOutline];
            [[pvc inputTextField] setStringValue:@""];
            [[self createCollectionPopover] close];
        }
        
    }
}

- (IBAction)createDBAction:(id)sender {
    // TODO: Fix that when the control loses focus, it adds DB
    CreateItemPopover *pvc = (CreateItemPopover *) [[self createDBPopover] contentViewController];
    NSString *newDBName = [[pvc inputTextField] stringValue];

    if (newDBName  && [newDBName length]>0)
    {
        newDBName = [newDBName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([[[self dataManager] ConnectionManager] createDBNamed:newDBName])
        {
            if ([[self createDBPopover] isShown])
            {
                NSLog(@"Closing");
                [[self createDBPopover] close];
            }
            NSLog(@"Refresh");
            [self setupDBsPopUpButton];

            [[pvc inputTextField] setStringValue:@""];
        }
        
    }
}

- (IBAction)showCreateDBPopoverWasPressed:(id)sender {
    [self showPopOver:[self createDBPopover] withSender:sender];
}

- (IBAction)dropDBWasPressed:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Do you really want to drop database?"
                                     defaultButton:@"Drop"
                                   alternateButton:@"Learn more"
                                       otherButton:@"Cancel"
                         informativeTextWithFormat:@"Deleting this item will erase all associated data in the database. This action cannot be undone."];
    
    [self setPopupAlert:alert];
    NSButton *sButton = (NSButton *) sender;
    [alert runAsPopoverForView:sButton withCompletionBlock:^(NSInteger result) {
		// handle result
        if (result==NSAlertFirstButtonReturn)
        {
            BOOL result = [[[self dataManager] ConnectionManager] dropDB:[self getSelectedDatabase]];
            if(result)
            {
                [self setupDBsPopUpButton];
                [self refrechCollectionOutline];
            }
            else
            {
                NSAlert *alert2 = [[NSAlert alloc] init];
                [alert2 setMessageText: [NSString stringWithFormat:@"Unable to drop database %@", [self getSelectedDatabase]]];
                [alert2 runModal];
                
            }
        }
	}];
    
}

- (IBAction)showUsersWasPressed:(id)sender {
}

- (IBAction)dbInfoButtonPressed:(id)sender {
    [[[self dataManager] ConnectionManager] getDBStats: [self getSelectedDatabase]];
    
}

- (IBAction)dbsPopUpButtonAction:(id)sender
{
    [[self collectionSearchField] setStringValue:@""];
    [self refrechCollectionOutline];
}

-(void) refrechCollectionOutline
{
    [self  setCollectionData:@[]];
    [[self dataManager] fetchCollectionNamesForDB: [self getSelectedDatabase]];
    [[self dataManager] processCollectionsWithFilter:[[self collectionSearchField] stringValue]];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [[self collectionListView]  selectRowIndexes:indexSet byExtendingSelection:NO];
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
    [[self sideBar] setConnectionURL: [[[self dataManager] ConnectionManager] connectionDecriptionString] ];
}

-(void) setupTabs
{
    [[self tabBarView] setTabView: [self tabView]];
    MMSafariTabStyle *style = [[MMSafariTabStyle alloc] init];
    [[self tabBarView] setStyle:style];
    
    [[self tabBarView] setDelegate:self];
    [[self tabBarView] setCanCloseOnlyTab:YES]; // The only tab left does not have a button
    
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
    if ([[[self collectionListTC] selectedNodes] count])
    {
        NSTreeNode *selectedNode = [[[self collectionListTC] selectedNodes] objectAtIndex:0];
        NSDictionary *selectedNodeObj = [selectedNode representedObject];
        NSString *selectedCollection = selectedNodeObj[@"name"];
        return selectedCollection;
    }
    return @"";
}

-(NSString *) getSelectedDatabase
{
    return [[[self dbsPopUpButton] selectedItem]  title];
}



# pragma mark - DataManager callbacks

-(void) setCollectionData: (NSArray *)data
{
    [self setCollectionListItems: data];
}

# pragma mark - MangoPluginDelegate

-(void) addPluginNamed: (NSString *) name withInstance:(id<MangoPlugin>) plugin
{
    MangoPluginTabItem *item = [[MangoPluginTabItem alloc] init];
    [item setTitle:name];
    [item setHasCloseButton:YES];
    NSTabViewItem *newTab = [[NSTabViewItem alloc] initWithIdentifier:item];
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

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
    [[self pluginManager] removePluginNamed:[tabViewItem label]];
    [[self tabBarView] setNeedsUpdate:YES];
}

#pragma mark - Outline delegate

- (NSCell*) outlineView:(NSOutlineView*) outlineView dataCellForTableColumn:(NSTableColumn*) tableColumn item:(id) item
{
    CollectionListCell *cell = [[CollectionListCell alloc] init];
    NSTreeNode *t_item = (NSTreeNode *) item;
    NSNumber * isGFS = [[t_item representedObject] valueForKey:@"GridFS"];

    if (isGFS  && [isGFS boolValue])
    {
        [cell setIsGridFS:YES];
    }
    return cell;
}


- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    return 25;
}

@end
