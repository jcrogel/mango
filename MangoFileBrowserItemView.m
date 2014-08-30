//
//  MangoFileBrowserItemView.m
//  Mango
//
//  Created by Juan Carlos Moreno on 8/29/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoFileBrowserItemView.h"

@implementation MangoFileBrowserItemView

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_selected) {
        [[NSColor lightGrayColor] set];
        NSRectFill([self bounds]);
    }
}

-(void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
	
	// check for click count above one, which we assume means it's a double click
	if([theEvent clickCount] > 1) {
		if ([self collectionView])
        {
            [[self collectionView] cellWasDoubleClicked];
        }
	}
}

@end
