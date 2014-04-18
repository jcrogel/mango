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
#import "MangoBrowserKeyCell.h"
#import "MangoBrowserValueCell.h"
#import "NSDate+SAMAdditions.h"
#import "MangoBrowserOutlineView.h"

@interface MangoBrowserView : NSViewController<MangoPlugin,
                                                    NSOutlineViewDataSource,
                                                    NSOutlineViewDelegate>
@property (weak) IBOutlet MangoBrowserOutlineView *outlineView;
@property (weak) IBOutlet NSButton *triggerButton;
@property (weak) IBOutlet NSButton *autorefreshCheckbox;
@property (weak) IBOutlet NSTextField *queryLimitTextField;
@property (strong) IBOutlet NSTreeController *browserTC;

- (IBAction)runQueryButtonWasPressed:(id)sender;

@property NSArray *dbData;

@end
