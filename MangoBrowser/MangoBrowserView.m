//
//  MangoBrowserView.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/13/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoBrowserView.h"

@implementation MangoBrowserView

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[self view] setAutoresizesSubviews: YES];
        [[self view] setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        self.dbData = @[];

    }

    return self;
}



- (IBAction)runQuery:(id)sender {
    
    NSLog(@"Nicely ");
}

-(BOOL) shouldAutoRefresh
{
    if([[self autorefreshCheckbox] state]== NSOnState)
        return YES;
    return NO;
}

#pragma mark - MangoPlugin

-(void) refreshDataFromDB: (NSString *) db withCollection: (NSString *) col andConnMgr: (MangoConnectionManager *) mgr
{
    if ([self shouldAutoRefresh])
    {
        NSArray *res = [mgr queryNameSpace: [NSString stringWithFormat:@"%@.%@", db, col ] withOptions: @{}];
        [self setDbData:res];
        [[self outlineView] reloadData];
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (!item)
    {
        return [[self dbData] count];
    }
    
    if ([item count]>0)
    {
        if ([item isKindOfClass:[NSDictionary class]])
        {
            id childItem = [item mutableCopy];
            [childItem removeObjectForKey:@"_id"];
            return [childItem count];
        }
    }
    // TODO: Fix
    return 0;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (item == nil) return YES;
    
    if ([item isKindOfClass: [NSDictionary class]] && [item count]>0)
    {
        return YES;
    }
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item)
    {
        id obj = [self dbData][index];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            return obj;
        }
    }
    else
    {
        id childItem = [item mutableCopy];
        [childItem removeObjectForKey:@"_id"];
        NSArray *keys = [[childItem keyEnumerator] allObjects];
        id key = [keys objectAtIndex:index];
        id retval = item[key];
        NSLog(@"class %@ %@", key,[retval class]);
        return retval;
    }
    
    return nil;
}


- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if (item)
    {
        if ([item isKindOfClass: [NSDictionary class]])
        {
            id oid = item[@"_id"];
            if (oid && [oid isKindOfClass: [NSDictionary class]])
            {
                NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell: oid[@"$oid"]];
                
                return cell;
            }
        }
        else
        {
            
        }
        
        
        NSLog(@"ABCD: %@", item);
    }
    
    return nil;
    
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    //NSLog(@"%@", [[self outlineView] selectedCell]);
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    //NSLog(@"%@ %@", tableColumn, item);
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if (item)
    {
        if ([item isKindOfClass: [NSDictionary class]])
        {
            id oid = item[@"_id"];
            if ([oid isKindOfClass: [NSDictionary class]])
            {
                return [NSString stringWithFormat:@"ObjectId(%@)", oid[@"$oid"] ];
            }
        }
    }
    
    return nil;
}

@end
