//
//  ConnectionBannerView.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/16/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "ConnectionBannerView.h"

@implementation ConnectionBannerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setWantsLayer:YES];
        [[self layer] setBackgroundColor:[NSColor blackColor].CGColor];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    // Drawing code here.
    
    [NSGraphicsContext saveGraphicsState];
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGAffineTransform transform1 = CGAffineTransformMakeRotation(-90 * M_PI/180.0);
    CGContextConcatCTM(context, transform1);
    
    CGContextTranslateCTM(context, -dirtyRect.size.height+95, 0);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = kCTTextAlignmentCenter;

    [[self connectionURL] drawAtPoint: NSMakePoint(0, 18) withAttributes:@{
                                                       NSFontAttributeName:[NSFont fontWithName:@"OpenSans-Semibold" size:23.0],
                                                       NSParagraphStyleAttributeName:paragraphStyle,
                                                       NSForegroundColorAttributeName: [NSColor lightGrayColor]
                                                       }];
    
    // Clean up
    [NSGraphicsContext restoreGraphicsState];
}

@end
