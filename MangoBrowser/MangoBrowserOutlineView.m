//
//  MangoBrowserOutlineView.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/17/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoBrowserOutlineView.h"

@implementation MangoBrowserOutlineView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)updateTrackingAreas {

    for (NSTrackingArea *area in [self trackingAreas]) {
        // We have to uniquely identify our own tracking areas
        if ([area owner] == self) {
            [self removeTrackingArea:area];
        }
    }
    
    // Find the visible cells that have a non-empty tracking rect and add rects for each of them
    NSRange visibleRows = [self rowsInRect:[self visibleRect]];
    NSIndexSet *visibleColIndexes = [self columnIndexesInRect:[self visibleRect]];
    
    NSPoint mouseLocation = [self convertPoint:[[self window] convertScreenToBase:[NSEvent mouseLocation]] fromView:nil];
    
    for (NSUInteger row = visibleRows.location; row < visibleRows.location + visibleRows.length; row++ ) {
        // If it is a "full width" cell, we don't have to go through the rows

        for (NSInteger col = [visibleColIndexes firstIndex]; col != NSNotFound; col = [visibleColIndexes indexGreaterThanIndex:col]) {
            NSCell *cell = [self preparedCellAtColumn:col row:row];
            if ([cell respondsToSelector:@selector(addTrackingAreasForView:inRect:withUserInfo:mouseLocation:)]) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:col], @"Col", [NSNumber numberWithInteger:row], @"Row", nil];
                [cell addTrackingAreasForView:self inRect:[self frameOfCellAtColumn:col row:row] withUserInfo:userInfo mouseLocation:mouseLocation];
            }
        }
        
    }
}

- (void)mouseEntered:(NSEvent *)event {
    
    // Delegate this to the appropriate cell. In order to allow the cell to maintain state,
    // we copy it and use the copy until the mouse is moved outside of the cell.
    //
    NSDictionary *userInfo = [event userData];
    NSNumber *row = [userInfo valueForKey:@"Row"];
    NSNumber *col = [userInfo valueForKey:@"Col"];
    if (row && col) {
        NSInteger rowVal = [row integerValue];
        NSInteger colVal = [col integerValue];
        NSCell *cell = [self preparedCellAtColumn:colVal row:rowVal];
        /*
        // Only set the mouseCell properties AFTER calling preparedCellAtColumn:row:.
        if (iMouseCell != cell) {
            [iMouseCell release];
            // Store off the col/row
            iMouseCol = colVal;
            iMouseRow = rowVal;
            // Store a COPY of the cell for use when tracking in an area
            iMouseCell = [cell copy];
            [iMouseCell setControlView:self];
            [iMouseCell mouseEntered:event];
         */
        [cell setControlView:self];
        [cell mouseEntered: event];
        //}
    }
}

-(void) mouseUp:(NSEvent *)event
{
    if (event.clickCount == 2) {
        NSLog(@"Double click");
    }
}

- (void)mouseExited:(NSEvent *)event {
    
    NSDictionary *userInfo = [event userData];
    NSNumber *row = [userInfo valueForKey:@"Row"];
    NSNumber *col = [userInfo valueForKey:@"Col"];
    if (row && col) {
        NSCell *cell = [self preparedCellAtColumn:[col integerValue] row:[row integerValue]];
        [cell setControlView:self];
        [cell mouseExited:event];
        // We are now done with the copied cell
        //iMouseCell = nil;
        //iMouseCol = -1;
        //iMouseRow = -1;
    }
}
@end
