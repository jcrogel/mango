//
//  MangoFileBrowserOutlineViewController.m
//  Mango
//
//  Created by Juan Carlos Moreno on 5/15/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoFileBrowserCollectionViewController.h"

@implementation MangoFileBrowserCollectionViewController



-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setDbData: [@[] mutableCopy]];
        [[self view] setAutoresizesSubviews: YES];
        [[self view] setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
    
    return self;
}

-(void) reloadData
{
    //NSLog(@"%@", [self dbData]);
    //[[self collectionView]  reloadData];
}

- (BOOL)isSelectable
{
    return YES;
}


@end
