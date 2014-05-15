//
//  MangoBrowserView.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/13/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoPlugin.h"
#import "MangoDataManager.h"
#import <Cocoa/Cocoa.h>
#import "NSDate+SAMAdditions.h"
#import "MangoBrowserOutlineView.h"
#import "MangoPluginTabItem.h"
#import "MangoFileBrowserOutlineView.h"
#import "MangoBrowserContainer.h"
#import "MangoBrowserOutlineViewContainer.h"


@interface MangoBrowserViewController : NSViewController<MangoPlugin,
                                                    NSOutlineViewDataSource,
                                                    NSOutlineViewDelegate>

@property (weak) IBOutlet NSButton *triggerButton;
@property (strong) IBOutlet NSTreeController *browserTC;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *messageInfo;
@property (weak) IBOutlet NSPredicateEditor *filterPredicateEditor;
@property (strong) IBOutlet NSPopover *fieldPopover;
@property (strong) IBOutlet NSPopover *filterPopover;
@property (strong) IBOutlet NSPopover *mapReducePopover;
@property (strong) IBOutlet NSPopover *indicesPopover;
@property (weak) IBOutlet NSView *toolBar;
@property (weak) IBOutlet NSView *browserContainer;

@property id<MangoBrowserContainer> dataView;

@property NSUInteger viewMode;
@property (assign) BOOL autoRefresh;
@property NSNumber *queryLimit;
@property NSString *queryNamespace;

- (IBAction)mapReduceButtonWasPressed:(id)sender;
- (IBAction)filterButtonWasPressed:(id)sender;
- (IBAction)runQueryButtonWasPressed:(id)sender;
- (IBAction)indicesButtonWasPressed:(id)sender;

@property NSMutableArray *dbData;

-(void) setSimpleMode;

@end
