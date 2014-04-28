//
//  MangoBrowserCell.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/16/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "MangoBrowserCell.h"


#define OBJECT_COLOR	[NSColor colorWithCalibratedRed:1 green:0.432 blue:0.503 alpha:1.000]
#define ARRAY_COLOR	[NSColor colorWithCalibratedRed:1 green:.6 blue:0.503 alpha:1]
#define STRING_COLOR	[NSColor colorWithCalibratedRed:.31 green:.64 blue:.97 alpha:1]
#define BOOL_COLOR	[NSColor colorWithCalibratedRed:1 green:.47 blue:.72 alpha:1]
#define NUMBER_COLOR	[NSColor colorWithCalibratedRed:.5 green:.65 blue:.14 alpha:1]
#define NULL_COLOR	[NSColor colorWithCalibratedRed:0.3 green:.3 blue:.3 alpha:1]

@implementation MangoBrowserCell

- (id) initTextCell:(NSString*)aString
{
	if ((self = [super initTextCell:aString]))
	{
        NSFont *font = [NSFont fontWithName:@"OpenSans-Light" size:13.0];
        [self setFont: font];
        trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
	}
	
	return self;
}


- (void)addTrackingAreasForView:(NSView *)controlView inRect:(NSRect)cellFrame withUserInfo:(NSDictionary *)userInfo mouseLocation:(NSPoint)mouseLocation {
    
    
    NSTrackingAreaOptions options = NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;
    
    // We make the view the owner, and it delegates the calls back to the cell after it is
    // properly setup for the corresponding row/column in the outlineview
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:cellFrame options:options owner:controlView userInfo:userInfo];
    [controlView addTrackingArea:area];
}

- (void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (mouseInside)
    {
        NSMutableAttributedString *str = [[self attributedStringValue] mutableCopy];
        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, str.length)];
        
        [self setAttributedStringValue:str];
    }
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];
    titleFrame.origin.y = theRect.origin.y - .5 + (theRect.size.height - titleSize.height) / 2.0;
    return titleFrame;
}


- (void)mouseEntered:(NSEvent *)theEvent {
    mouseInside = YES;
    [[NSCursor pointingHandCursor] set];
    [(NSControl *)[self controlView] updateCellInside:self];
    [(NSControl *)[self controlView] updateCell:self];
}

- (void)mouseExited:(NSEvent *)theEvent {
    mouseInside = NO;
    [[NSCursor arrowCursor] set];
    [(NSControl *)[self controlView] updateCellInside:self];
    [(NSControl *)[self controlView] updateCell:self];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    
}

- (void)mouseUp:(NSEvent *)theEvent
{

}


@end
