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
    //[self loadWindow];
    [[self connMgr] dbgConn];
    [self window];
}

- (IBAction)debugConn:(id)sender {
}

- (void)windowDidLoad
{
    [super windowDidLoad];

	_fragaria = [[MGSFragaria alloc] init];
	[_fragaria setObject:self forKey:MGSFODelegate];
    [_fragaria setObject:self forKey:MGSFOSyntaxColouringDelegate];
    [_fragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
    [_fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];

	[_fragaria embedInView:[self sourceEditor]];
    
   // [[self sourceEditor] setWantsLayer:YES];
   // [[self sourceEditor].layer setBackgroundColor: [NSColor redColor].CGColor];

}

@end
