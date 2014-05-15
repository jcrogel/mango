//
//  MangoBrowserOutlineViewContainer.h
//  Mango
//
//  Created by Juan Carlos Moreno on 5/14/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoBrowserOutlineView.h"
#import "MangoBrowserContainer.h"
#import "MangoBrowserKeyCell.h"
#import "MangoBrowserValueCell.h"
#import <Cocoa/Cocoa.h>


@interface MangoBrowserOutlineViewContainer : NSViewController<MangoBrowserContainer,
                                                                NSOutlineViewDataSource,
                                                                NSOutlineViewDelegate>

@property (strong) IBOutlet NSTreeController *browserTC;
@property (weak) IBOutlet MangoBrowserOutlineView *outlineView;
@property NSMutableArray *dbData;


@end
