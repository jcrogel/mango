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
        [self setRefreshRate:[NSNumber numberWithInt:5]];
        [self setPulses:[NSNumber numberWithBool:YES]];
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



-(void) getServerInfo
{
    BOOL shouldRefresh = [[self pulses] boolValue];
    float refreshRate = [[self refreshRate] floatValue];
    if (shouldRefresh && refreshRate)
    {
        NSLog(@"Dispatching");
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, refreshRate * NSEC_PER_SEC, 2 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            id json = [[[self dataManager] ConnectionManager] getServerStatus];
            NSLog(@"%@", json);
        });
        dispatch_resume(timer);
        
    }
    
    
   // NSLog(@"Do I have a dataMGR %@", [self dataManager] );
    //NSLog(@"%@", json);
}


@end
