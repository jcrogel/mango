//
//  MangoBrowserView.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/13/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoBrowserView.h"

@implementation MangoBrowserView

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[self view] setAutoresizesSubviews: YES];
        [[self view] setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }

    return self;
}



- (IBAction)runQuery:(id)sender {
    NSLog(@"Nicely");
}


#pragma mark - MangoPlugin

-(void) refreshDataFromDB: (NSString *) db withCollection: (NSString *) col andConnMgr: (MangoConnectionManager *) mgr
{
    
}

@end
