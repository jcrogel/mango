//
//  InfoWindowController.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/17/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MangoDataManager.h"

@interface InfoWindowController : NSWindowController
@property (weak) IBOutlet NSView *cal;
@property (weak) IBOutlet NSDatePicker *calendar;
@property MangoDataManager *dataManager;
@property NSNumber *refreshRate;
@property NSNumber *pulses;

-(void) getServerInfo;

@end
