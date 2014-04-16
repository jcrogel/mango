//
//  MangoBrowserView.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/13/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoPlugin.h"
#import "MangoConnectionManager.h"
#import <Cocoa/Cocoa.h>
#import "MangoBrowserCell.h"
#import "MangoBrowserValueCell.h"

@interface MangoBrowserView : NSViewController<MangoPlugin,
                                                    NSOutlineViewDataSource,
                                                    NSOutlineViewDelegate>
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSButton *triggerButton;
- (IBAction)runQuery:(id)sender;
@property (weak) IBOutlet NSButton *autorefreshCheckbox;
@property (weak) IBOutlet NSTextField *queryLimitTextField;

@property (strong) IBOutlet NSTreeController *browserTC;

@property NSArray *dbData;

@end
