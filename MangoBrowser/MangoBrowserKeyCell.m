//
//  MangoBrowserKeyCell.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/18/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoBrowserKeyCell.h"


#define OBJECT_COLOR	[NSColor colorWithCalibratedRed:1 green:0.432 blue:0.503 alpha:1.000]
#define ARRAY_COLOR	[NSColor colorWithCalibratedRed:1 green:.6 blue:0.503 alpha:1]
#define STRING_COLOR	[NSColor colorWithCalibratedRed:.31 green:.64 blue:.97 alpha:1]
#define BOOL_COLOR	[NSColor colorWithCalibratedRed:1 green:.47 blue:.72 alpha:1]
#define NUMBER_COLOR	[NSColor colorWithCalibratedRed:.5 green:.65 blue:.14 alpha:1]
#define NULL_COLOR	[NSColor colorWithCalibratedRed:0.3 green:.3 blue:.3 alpha:1]

@implementation MangoBrowserKeyCell



- (void) drawBadgeInFrame: (NSRect)objTypeRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGColorRef color = OBJECT_COLOR.CGColor;
    NSString *badgeStr = @"O";
    
    if (![self dataType])
    {
        [self setDataType:@"Dictionary"];
    }
    
    if ([[self dataType] isEqualToString:@"Dictionary"])
    {
        color = OBJECT_COLOR.CGColor;
    }
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
    
    
    if([[self dataType] isNotEqualTo:@"ObjectID"])
    {
        CGContextSetFillColorWithColor(ctx, color);
        CGContextFillEllipseInRect(ctx, objTypeRect);
        
        NSRect badgeStrRect = objTypeRect;
        badgeStrRect.origin.y -=4;
        
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
    }
    else
    {
        NSImage *image = [NSImage imageNamed:@"mongo_obj_badge"];
        [image drawInRect:objTypeRect];
    }
    
    if ([self modifiedBadge] && [[self modifiedBadge] isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        CGContextSaveGState(ctx);
        
        CGRect badgeModRect = CGRectMake(37,1.50,7.00,7.00);
        CGMutablePathRef pElip_0 = CGPathCreateMutable();
        CGPathAddEllipseInRect(pElip_0, NULL, badgeModRect);
        CGContextSetRGBStrokeColor(ctx,1.0000,1.0000,1.0000,1.0000);
        
        CGContextSetFillColorWithColor(ctx, [NSColor colorWithCalibratedRed:1 green:.29 blue:.29 alpha:1].CGColor);

        CGContextFillEllipseInRect(ctx, badgeModRect);
        CGContextSetLineWidth(ctx, 1);
        
        CGContextAddPath(ctx, pElip_0);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGPathRelease(pElip_0);
        CGContextRestoreGState(ctx);
    }
    
}


- (void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    
    NSRect objTypeRect = CGRectMake(cellFrame.origin.x+5, cellFrame.origin.y+2,
                                    cellFrame.size.height-4, cellFrame.size.height-4);
    [self drawBadgeInFrame: objTypeRect];
    
    NSRect textFrame = cellFrame;
    textFrame.origin.x += 28;
    
	[super drawInteriorWithFrame:textFrame inView:controlView];
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];
    titleFrame.origin.y = theRect.origin.y - .5 + (theRect.size.height - titleSize.height) / 2.0;
    return titleFrame;
}

@end
