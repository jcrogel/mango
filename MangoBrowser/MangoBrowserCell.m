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
	}
	
	return self;
}



- (void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    CGContextRef ctx = [[NSGraphicsContext // 1
                               currentContext] graphicsPort];
    NSRect objTypeRect = CGRectMake(cellFrame.origin.x+5, cellFrame.origin.y+2, cellFrame.size.height-4, cellFrame.size.height-4);
    
    CGColorRef color = OBJECT_COLOR.CGColor;
    
    if ([self dataType])
    {
        if ([[self dataType] isEqualToString:@"Array"])
        {
            color = ARRAY_COLOR.CGColor;
        }
        if ([[self dataType] isEqualToString:@"String"])
        {
            color = STRING_COLOR.CGColor;
        }
        if ([[self dataType] isEqualToString:@"Bool"])
        {
            color = BOOL_COLOR.CGColor;
        }
        if ([[self dataType] isEqualToString:@"Null"])
        {
            color = NULL_COLOR.CGColor;
        }
        if ([[self dataType] isEqualToString:@"Number"])
        {
            color = NUMBER_COLOR.CGColor;
        }
        
    }
    CGContextSetFillColorWithColor(ctx, color);
    CGContextFillEllipseInRect(ctx, objTypeRect);
    
    NSRect textFrame = cellFrame;
    textFrame.origin.x += 28;
    
    
    NSRect badgeStrRect = objTypeRect;
    badgeStrRect.origin.y -=4;
    
    NSString *badgeStr = @"O";// substringWithRange:NSMakeRange(
    if ([self dataType])
    {
        if (![[self dataType] isEqualToString:@"Dictionary"] && ![[self dataType] isEqualToString:@"Null"])
        {
            badgeStr = [[self dataType] substringWithRange:NSMakeRange(0, 1)];
        }
        if ([[self dataType] isEqualToString:@"Null"])
        {
            badgeStr = @"-";
        }
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    /// Set text alignment
    paragraphStyle.alignment = kCTTextAlignmentCenter;
    [badgeStr drawInRect:badgeStrRect withAttributes:@{
                                    NSFontAttributeName:[NSFont fontWithName:@"OpenSans-Light" size:13.0],
                                    NSParagraphStyleAttributeName:paragraphStyle,
                                    NSForegroundColorAttributeName: [NSColor whiteColor]
                                    }];
    
    
	[super drawInteriorWithFrame:textFrame inView:controlView];
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];
    titleFrame.origin.y = theRect.origin.y - .5 + (theRect.size.height - titleSize.height) / 2.0;
    return titleFrame;
}


@end
