//
//  MangoFileBrowserOutlineView.m
//  Mango
//
//  Created by Juan Carlos Moreno on 5/14/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoFileBrowserCollectionView.h"

@implementation MangoFileBrowserCollectionView


-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code here.
        [self setSelectable:YES];

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void) cellWasDoubleClicked
{
    
     NSCollectionViewItem *item = [self itemAtIndex:[[self selectionIndexes] firstIndex]];

    NSLog(@"Cell was double clicked %@", [item representedObject]);
}

@end
