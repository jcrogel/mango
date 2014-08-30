//
//  MangoFileBrowserItem.m
//  Mango
//
//  Created by Juan Carlos Moreno on 8/29/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoFileBrowserItem.h"

@implementation MangoFileBrowserItem

-(void) mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    NSLog(@"Mouse Down On Cell");
}

- (void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    MangoFileBrowserItemView *view = (MangoFileBrowserItemView *)[self view];
    [view setSelected:flag];
    [view setNeedsDisplay:YES];
    [view setCollectionView:(MangoFileBrowserCollectionView *)[self collectionView]];
}



@end
