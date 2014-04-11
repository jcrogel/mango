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
    [[self connMgr] openConnection];
    [self window];
}

- (IBAction)debugConn:(id)sender {
}

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
    MMCardTabStyle *style = [[MMCardTabStyle alloc] init];
    [[self tabBarView] setStyle:style];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self setupTextEditor];
    [self setupDBsPopUpButton];
    [self setupSideBar];
    [self setupTabs];

}

#pragma mark -- 

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
