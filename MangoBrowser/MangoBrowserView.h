//
//  MangoBrowserView.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/13/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoPlugin.h"
#import <Cocoa/Cocoa.h>

@interface MangoBrowserView : NSViewController<MangoPlugin>
@property (weak) IBOutlet NSTableColumn *outlineView;
@property (weak) IBOutlet NSButton *triggerButton;
- (IBAction)runQuery:(id)sender;

@end
