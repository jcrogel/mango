//
//  CollectionListCell.m
//  Mango
//
//  Created by Juan Carlos Moreno on 5/4/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "CollectionListCell.h"

@implementation CollectionListCell

- (id) initTextCell:(NSString*)aString
{
	if ((self = [super initTextCell:aString]))
	{
        NSFont *font = [NSFont fontWithName:@"OpenSans-Light" size:13.0];
        [self setFont: font];
	}
	
	return self;
}


- (void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    
    NSRect objTypeRect = CGRectMake(cellFrame.origin.x-10, cellFrame.origin.y+3,
                                    12, 15);
    
    if ([self isGridFS])
    {
        NSImage *image = [NSImage imageNamed:@"GridFSCollection"];
        [image drawInRect:objTypeRect];
    }
    
    
    NSRect textFrame = cellFrame;
    textFrame.origin.y -= 3;
    textFrame.origin.x += 3;
    
	[super drawInteriorWithFrame:textFrame inView:controlView];
}



@end
