//
//  MangoBrowserOutlineViewContainer.m
//  Mango
//
//  Created by Juan Carlos Moreno on 5/14/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoBrowserOutlineViewContainer.h"

@implementation MangoBrowserOutlineViewContainer

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setDbData: [@[] mutableCopy]];
        [[self view] setAutoresizesSubviews: YES];
        [[self view] setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
    
    return self;
}

-(void) reloadData
{
    [[self outlineView] reloadData];
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), item);
}

- (NSCell*) outlineView:(NSOutlineView*) outlineView dataCellForTableColumn:(NSTableColumn*) tableColumn item:(id) item
{
    NSDictionary *rObj = [item representedObject];
    
    if (rObj && [rObj objectForKey:@"Type"])
    {
        NSCell *cell;
        if ([[outlineView tableColumns] objectAtIndex:0] == tableColumn)
        {
            // Key
            MangoBrowserKeyCell *_cell = [[MangoBrowserKeyCell alloc] init];
            
            NSString *type = [rObj objectForKey:@"Type"];
            
            if ( type && [[rObj objectForKey:@"Type"] isEqualToString:@"ObjectID"])
            {
                if([rObj objectForKey:@"Modified"])
                {
                    [_cell setModifiedBadge:[NSNumber numberWithBool:YES]];
                }
            }
            [_cell setDataType: type];
            
            cell = _cell;
        }
        else if ([[outlineView tableColumns] objectAtIndex:1] == tableColumn)
        {
            MangoBrowserValueCell *_cell = [[MangoBrowserValueCell alloc]init];
            [_cell setDataType:[rObj objectForKey:@"Type"]];
            cell = _cell;
        }
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc removeObserver:self name:NSControlTextDidEndEditingNotification object:[self outlineView]];
        [nc addObserver:self selector:@selector(endEditNotification:)   name:NSControlTextDidEndEditingNotification object:[self outlineView]];
        
        return cell;
    }
    
    return [tableColumn dataCell];
}


-(void) endEditNotification:(NSNotification *) notification
{
    
    NSInteger row = [[self outlineView] selectedRow];
    NSTreeNode *node = [[self outlineView] itemAtRow:row];
    NSTreeNode *parent = [node parentNode];
    
    while (parent)
    {
        NSTreeNode *newParent = [parent parentNode];
        
        if (newParent)
        {
            node = parent;
            parent = newParent;
            
        }
        else
        {
            break;
        }
    }
    
    NSMutableDictionary *rObj = [node representedObject];
    NSString *type = [rObj valueForKey:@"Type"];
    
    if ([type isEqualToString:@"ObjectID"])
    {
        [rObj setValue:[NSNumber numberWithBool:YES] forKey:@"Modified"];
    }
    
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    return 25;
}

@end
