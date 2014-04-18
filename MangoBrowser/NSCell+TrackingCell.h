//
//  NSCell+TrackingCell.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/17/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSCell (TrackingCell)
#import <Cocoa/Cocoa.h>

- (void)addTrackingAreasForView:(NSView *)view inRect:(NSRect)cellFrame withUserInfo:(NSDictionary *)userInfo mouseLocation:(NSPoint)currentPoint;

- (void)mouseEntered:(NSEvent *)event;
- (void)mouseExited:(NSEvent *)event;

@end
