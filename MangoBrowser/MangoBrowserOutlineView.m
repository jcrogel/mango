//
//  MangoBrowserOutlineView.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/17/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoBrowserOutlineView.h"
#import "MangoWindowController.h"

@implementation MangoBrowserOutlineView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setTarget:self];
        [self setDoubleAction:@selector(doubleClick:)];
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
        NSTreeNode *item = [self itemAtRow:rowVal];
        if([[item representedObject] valueForKey:@"Links"])
        {
            if (iMouseCell != cell) {
                // Store off the col/row
                iMouseCol = colVal;
                iMouseRow = rowVal;
                iMouseCell = [cell copy];
                [iMouseCell setControlView:self];
                [iMouseCell mouseEntered: event];
            }
        }
    }
}

-(void) doubleClick:(NSEvent *)event
{
    NSTreeNode *item = [self itemAtRow:[self clickedRow]];
    NSDictionary *rObj = [item representedObject];
    NSNumber *editableN = [rObj valueForKey:@"Editable"];
    id link = [rObj valueForKey:@"Links"];
    
    
    if (!editableN || [editableN boolValue]==NO)
    {
        if (link)
        {
            NSString *dataType = [rObj valueForKey:@"Type"];
            if (dataType && [dataType isEqualToString:@"ObjectID"])
            {
                NSString *value = [rObj valueForKey:@"Value"];
                NSString *title = [NSString stringWithFormat:@"ObjectID(%@)", value];
                id<MangoPluginDelegate> mangoWC = [[self window] windowController];
                MangoSimpleBrowserVC *simpleBrowser = [[MangoSimpleBrowserVC alloc]
                                            initWithNibName:@"MangoSimpleBrowserVC" bundle:
                                            [NSBundle bundleForClass:[self class]]];
                [[mangoWC dataManager] getObjectID: value];
                [mangoWC addPluginNamed:title withInstance:simpleBrowser];
            }
            
        }
    }
    else
    {
        [self editColumn:[self clickedColumn] row:[self clickedRow] withEvent:nil select:YES];
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
        iMouseCell = nil;
        iMouseCol = -1;
        iMouseRow = -1;
    }
}



- (NSCell *)preparedCellAtColumn:(NSInteger)column row:(NSInteger)row
{
    if ([self selectedCell] == nil && (row == iMouseRow) && (column == iMouseCol) && iMouseCell) {
        return iMouseCell;
    }
    return [super preparedCellAtColumn:column row:row];
    
}

- (void)updateCell:(NSCell *)aCell {
    
    if (aCell == iMouseCell) {
        [self setNeedsDisplayInRect:[self frameOfCellAtColumn:iMouseCol row:iMouseRow]];
    } else {
        [super updateCell:aCell];
    }
}
@end
