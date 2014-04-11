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
        MangoConnectionManager *connMgr = [[MangoConnectionManager alloc] init];
        [self setConnMgr: connMgr];
    }
    return self;
}

- (IBAction)runCommand:(id)sender {
    NSString *jsSource = [[self fragaria] string];
    NSString *dbName = [[[self dbsPopUpButton] selectedItem]  title];
    NSString *result = [[self connMgr] eval:jsSource onDB:dbName];
    NSLog(@"%@", result);
}

- (void) connectAndShow
{
    [[self connMgr] openConnection];
    [self window];
}

- (IBAction)debugConn:(id)sender {
}

#pragma mark - UI Setup

- (IBAction)dbsPopUpButtonAction:(id)sender {
    NSArray *collections = [[self connMgr] getCollectionNames: [[[self dbsPopUpButton] selectedItem] title]];
    [self setCollectionList: collections];
}

-(void) setupTextEditor
{
    _fragaria = [[MGSFragaria alloc] init];
	[_fragaria setObject:self forKey:MGSFODelegate];
    [_fragaria setObject:self forKey:MGSFOSyntaxColouringDelegate];
    [_fragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
    [_fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
	[_fragaria embedInView:[self sourceEditor]];
}

-(void) setupDBsPopUpButton
{
    NSArray * dbs = [[self connMgr] getDatabases];
    [[self dbsPopUpButton] removeAllItems];
    [[self dbsPopUpButton] addItemsWithTitles:dbs];
}

-(void) setupSideBar
{
    [[self sideBar] setBackgroundColor:[NSColor darkGrayColor]];
    [[self sideBar] addItemWithImage: [NSImage imageNamed:@"AppIcon"]];
}

-(void) setupTabs
{
    [[self tabBarView] setTabView: [self tabView]];
    MMSafariTabStyle *style = [[MMSafariTabStyle alloc] init];
    [[self tabBarView] setStyle:style];
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
    [self setupTextEditor];
    [self setupDBsPopUpButton];
    [self setupSideBar];
    [self setupTabs];

}

#pragma mark - Collection List

- (void)setCollectionList:(NSArray *)cl
{
    NSMutableDictionary *aux = [NSMutableDictionary new];
    
    NSString *rootTitle;
    for (NSString *cl_fullname in cl)
    {
        NSArray *fname_elements = [cl_fullname componentsSeparatedByString:@"."];
        NSUInteger length = [fname_elements count];
        NSMutableDictionary *ptr = aux;
        if (!rootTitle)
        {
            rootTitle = fname_elements[0];
        }
        
        for (int i=1; i<length; i++)
        {
            if (i == length-1)
            {
                // Last item
                [ptr setObject:@"" forKey:fname_elements[i]];
            }else
            {
                NSMutableDictionary *column = [ptr valueForKey:fname_elements[i]];
                if (column)
                {
                    ptr = column;
                }
                else
                {
                    NSMutableDictionary *value = [@{} mutableCopy];
                    [ptr setObject:value forKey:fname_elements[i]];
                    ptr = value;
                }
            }
        }
    }
    
    NSMutableArray *rootArray = [NSMutableArray new];
    
    /// THIS NEEDS TO SUPPORT CHILDREN
    for (id rootKey in aux)
    {
        id value = aux[rootKey];
        
        if ([value isKindOfClass:[NSString class]])
        {
            NSMutableDictionary *item = [NSMutableDictionary new];
            item[@"name"] = rootKey;
            item[@"children"] = @[];
            [rootArray addObject:item];
        }
        else
        {
            // Forward Pointer
        }
    }
    
    [self setCollectionListItems:rootArray];
}


-(void) outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


@end
