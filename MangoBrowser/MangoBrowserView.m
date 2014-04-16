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
        res = [self reformatQueryResults:res];
        [self setDbData:res];
        [[self outlineView] reloadData];
    }
}

-(NSArray *) reformatQueryResults: (NSArray *) data
{
    // ROOT
    NSMutableArray *retval = [@[] mutableCopy];
    for (id item in data)
    {
        if ([item isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary *reformattedItem = [@{} mutableCopy];
            NSString *title = @"";
            id oid = item[@"_id"];
            if (oid && [oid isKindOfClass: [NSDictionary class]])
            {
               title = [NSString stringWithFormat:@"ObjectId %@", oid[@"$oid"]];
            }
            
            reformattedItem[@"Name"] = title;
            
            NSArray *children = [self reformatJSONDict: item];
            reformattedItem[@"Children"] = children;
            reformattedItem[@"Type"] = @"Dictionary";
            [retval addObject:reformattedItem];
        }
        else
        {
            NSLog(@"OOPS %@", item);
        }
    }
    
    return retval;
}

-(NSDictionary *) reformatJSONValue: (id) value withName: (NSString *) name
{
    NSMutableDictionary *reformattedItem = [@{} mutableCopy];
    reformattedItem[@"Name"] = name;
    
    if ([value isKindOfClass:[NSDictionary class]])
    {
        NSArray *children = [self reformatJSONDict: value];
        reformattedItem[@"Children"] = children;
        reformattedItem[@"Type"] = @"Dictionary";
    }
    else if ([value isKindOfClass:[NSArray class]])
    {
        NSMutableArray *reformattedChildren = [@[] mutableCopy];
        for (int i=0; i<[value count]; i++)
        {
            NSDictionary *reformattedChild = [self reformatJSONValue:[value objectAtIndex:i] withName:[NSString stringWithFormat:@"%d", i ]];
            [reformattedChildren addObject:reformattedChild];
        }
        reformattedItem[@"Children"] = reformattedChildren;
        reformattedItem[@"Value"] = [NSNumber numberWithLong:[value count]];
        reformattedItem[@"Type"] = @"Array";
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        reformattedItem[@"Value"] = value;
        reformattedItem[@"Type"] = @"String";
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        reformattedItem[@"Value"] = value;
        
        if ([value isKindOfClass:[[NSNumber numberWithBool: YES] class]])
        {
            reformattedItem[@"Type"] = @"Bool";
        }
        else
        {
            reformattedItem[@"Type"] = @"Number";
        }
    }
    else if([value isKindOfClass:[NSNull class]])
    {
        reformattedItem[@"Value"] = @"";
        reformattedItem[@"Type"] = @"Null";
    }
    else
    {
        
        NSLog(@"Unknown %@ %@", name ,[value class]);
    }
    return reformattedItem;
}

-(NSArray *) reformatJSONDict: (NSDictionary *) data
{
    NSMutableArray *retval = [@[] mutableCopy];
    for (id key in [data keyEnumerator])
    {
        id value = data[key];
        NSDictionary *reformattedItem = [self reformatJSONValue:value withName:key];
        [retval addObject:reformattedItem];
    }
    return retval;
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), item);
}

- (NSCell*) outlineView:(NSOutlineView*) outlineView dataCellForTableColumn:(NSTableColumn*) tableColumn item:(id) item
{
//    NSLog(@"%d", );
    NSDictionary *rObj = [item representedObject];
    
    if (rObj && [rObj objectForKey:@"Type"])
    {
        if ([[outlineView tableColumns] objectAtIndex:0] == tableColumn)
        {
            // Key
            MangoBrowserCell *cell = [[MangoBrowserCell alloc] init];
            [cell setDataType:[rObj objectForKey:@"Type"]];
            return cell;
        }
        else if ([[outlineView tableColumns] objectAtIndex:1] == tableColumn)
        {
            MangoBrowserValueCell *cell = [[MangoBrowserValueCell alloc]init];
            [cell setDataType:[rObj objectForKey:@"Type"]];
            return cell;
        }
        
    }
    
    return [tableColumn dataCell];
}


- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    return 25;
}
@end
