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
                MangoBrowserViewController *simpleBrowser = [[MangoBrowserViewController alloc]
                                            initWithNibName:@"MangoBrowserViewController" bundle:
                                            [NSBundle bundleForClass:[self class]]];
                [simpleBrowser setSimpleMode];
                MangoWindowController *mwc = (MangoWindowController *) mangoWC;
                
                if(mwc)
                {
                    [[mangoWC dataManager] getObjectID: value onDB:[mwc getSelectedDatabase]];
                    [mangoWC addPluginNamed:title withInstance:simpleBrowser];

                }
            }
            
        }
    }
    else
    {
        [self editColumn:[self clickedColumn] row:[self clickedRow] withEvent:nil select:YES];
    }
}

- (void) rightMouseDown: (NSEvent*) theEvent
{
    [super rightMouseDown:theEvent];
    
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    long row = [self rowAtPoint:p];
    long column = [self columnAtPoint:p];
    NSTreeNode *item = [self itemAtRow:row];
    
    NSCell *cell = [self preparedCellAtColumn:column row: row];
    if ([cell isKindOfClass:[MangoBrowserCell class]])
    {
        MangoBrowserCell *mcell = (MangoBrowserCell *)cell;
        [self rightClickOnCell: mcell treeNode:item andEvent:theEvent];
    }
}

#pragma mark - Right mouse options

-(void) copyToJSONClipboard: (id) sender
{
    MangoWindowController *mwc = (MangoWindowController *) [[self window] windowController];
    
    if(mwc && [mwc isKindOfClass:[MangoWindowController class]])
    {
        id jsonObj = [[mwc dataManager] mangoToJSON: [sender representedObject]];
        NSError *e;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error: &e];

        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
        [pasteBoard setString: jsonStr forType:NSStringPboardType];
    }
}

-(void) copyToClipboard: (id) sender
{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString: [sender representedObject] forType:NSStringPboardType];
}

-(void) saveDocument: (id) sender
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Not Implemented" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Yo get on this shit and fix it!"];
    [alert runModal];
}

-(void) exportDocument: (id) sender
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Not Implemented" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Yo get on this shit and fix it!"];
    [alert runModal];
}


-(void) duplicateItem: (id) sender
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Not Implemented" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Yo get on this shit and fix it!"];
    [alert runModal];
}


-(void)rightClickOnCell: (MangoBrowserCell *) cell treeNode: (NSTreeNode *) item andEvent: (NSEvent *)theEvent
{
    NSDictionary *representedObject = [item representedObject];
    if (!representedObject || ![representedObject isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSString *dataType = [representedObject valueForKey:@"Type"];
    if (!dataType)
    {
        return;
    }
    

    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    if ([ dataType isEqualToString:@"String"])
    {
        //[theMenu insertItemWithTitle:@"Beep" action:@selector(beep:) keyEquivalent:@"" atIndex:0];
    }
    
    if ([dataType isEqualToString:@"ObjectID"])
    {
        NSMenuItem *saveMI = [[NSMenuItem alloc] initWithTitle:@"Save Document" action:nil keyEquivalent:@""];

        if ([representedObject valueForKey:@"Modified"])
        {
            [saveMI setAction:@selector(saveDocument:)];
            [saveMI setRepresentedObject:representedObject];
        }
        [theMenu addItem:saveMI];
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Export Document as" action:@selector(exportDocument:) keyEquivalent:@""];
        [menuItem setRepresentedObject:representedObject];
        [theMenu addItem:menuItem];
    }

    NSMenuItem *separator = [NSMenuItem separatorItem];
    [theMenu addItem:separator];

    NSString *value = [representedObject valueForKey:@"Value"];
    if (value && [value length])
    {
        NSMenuItem *copyMI = [[NSMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyToClipboard:) keyEquivalent:@""];
        [copyMI setRepresentedObject:value];
        [theMenu addItem:copyMI];
    }
    
    NSMenuItem *copyJSONMI = [[NSMenuItem alloc] initWithTitle:@"Copy as JSON" action:@selector(copyToJSONClipboard:) keyEquivalent:@""];
    [copyJSONMI setRepresentedObject:representedObject];
    [theMenu addItem:copyJSONMI];

    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Duplicate" action:@selector(duplicateItem:) keyEquivalent:@""];
    [menuItem setRepresentedObject:representedObject];
    [theMenu addItem:menuItem ];
    
    
    [NSMenu popUpContextMenu:theMenu withEvent:theEvent forView:self];
    
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
