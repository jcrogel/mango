//
//  InfoWindowController.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/17/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "InfoWindowController.h"
#import "CKCalendarView.h"

@interface InfoWindowController ()

@end

@implementation InfoWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    ///CGRect rect = NSRectToCGRect([[self cal] frame]);
    //CKCalendarView *ckv = [[CKCalendarView alloc] initWithFrame: rect];
    //[ckv setWantsLayer:YES];
    //[ckv setTitleFont:[NSFont fontWithName:@"AvenirNext-DemiBold" size:15.0]];
    //[ckv setDateOfWeekFont:[NSFont fontWithName:@"OpenSans-Regular" size:15.0]];
    //[ckv setDateFont:[NSFont fontWithName:@"OpenSans-Light" size:13.0]];
    //[[ckv layer] setBackgroundColor: [NSColor whiteColor].CGColor];
    //[[self cal] addSubview:ckv];
    


    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
