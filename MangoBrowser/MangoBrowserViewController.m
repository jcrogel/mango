//
//  MangoBrowserView.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/13/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoBrowserViewController.h"

@implementation MangoBrowserViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[self view] setAutoresizesSubviews: YES];
        [[self view] setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        self.dbData = @[];

    }

    return self;
}


-(BOOL) shouldAutoRefresh
{
    if([[self autorefreshCheckbox] state]== NSOnState)
        return YES;
    return NO;
}

#pragma mark - MangoPlugin

-(void) refreshDataFromDB: (NSString *) db withCollection: (NSString *) col andDataManager: (MangoDataManager *) mgr
{
    if ([self shouldAutoRefresh])
    {
        [[self progressBar] startAnimation:self];
        [[self progressBar] setHidden: NO];
        [[[self progressBar] animator] setAlphaValue:1];
        [[self messageInfo] setStringValue: [NSString stringWithFormat:@"Loading %@.%@", db, col]];
        NSDate *start = [NSDate date];
        NSMutableDictionary *options = [@{} mutableCopy];
        
        if (![[[self queryLimitTextField] stringValue] isEqualToString:@"0"])
        {
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * limit = [f numberFromString:[[self queryLimitTextField] stringValue]];
            options[@"limit"] = limit;
        }
        
        NSArray *res = [[mgr ConnectionManager] queryNameSpace: [NSString stringWithFormat:@"%@.%@", db, col ] withOptions: options];
        res = [self reformatQueryResults:res];
        [self setDbData:res];
        [[self outlineView] reloadData];
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        [[self progressBar] stopAnimation:self];
        [[[self progressBar] animator] setAlphaValue:0.0];
        [[self messageInfo] setStringValue: [NSString stringWithFormat:@"Loaded %@.%@ in %f", db, col, timeInterval]];
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
            reformattedItem[@"Type"] = @"Dictionary";
            
            NSString *title = @"";
            id oid = item[@"_id"];
            if (oid && [oid isKindOfClass: [NSDictionary class]] && [oid valueForKey:@"$oid"])
            {
                title = @"Document";
                reformattedItem[@"Type"] = @"ObjectID";
                reformattedItem[@"Value"] = [NSString stringWithFormat:@"%@", oid[@"$oid"]];
            }
            
            reformattedItem[@"Name"] = title;
            // remove _id from view
            NSMutableDictionary *cleanedItem = [item mutableCopy];
            [cleanedItem removeObjectForKey:@"_id"];
            NSArray *children = [self reformatJSONDict: cleanedItem];
            reformattedItem[@"Children"] = children;
            
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
    reformattedItem[@"Editable"] = [NSNumber numberWithBool: YES];
    if ([value isKindOfClass:[NSDictionary class]])
    {
        
        NSMutableDictionary *cleanedItem = [value mutableCopy];
    
        reformattedItem[@"Type"] = @"Dictionary";
        reformattedItem[@"Value"] = [NSString stringWithFormat:@"{ %@ }", [NSNumber numberWithLong:[value count]]];
        
        if ([cleanedItem valueForKey:@"$oid"])
        {
            id rOID = [cleanedItem valueForKey:@"$oid"];
            reformattedItem[@"Type"] = @"ObjectID";
            reformattedItem[@"Value"] = [NSString stringWithFormat:@"%@", rOID];
            reformattedItem[@"Links"] = [rOID copy];
            reformattedItem[@"Editable"] = [NSNumber numberWithBool: NO];
            [cleanedItem removeObjectForKey:@"$oid"];
        }
        
        if ([cleanedItem valueForKey:@"$date"])
        {
            id date = [cleanedItem valueForKey:@"$date"];
            if([date isKindOfClass:[NSString class]])
            {
                reformattedItem[@"Type"] = @"Date";

                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS.SSSZ"];
                
                NSDate *myDate = [dateFormatter dateFromString:date];
                
                NSDateFormatter *anotherDateFormatter = [[NSDateFormatter alloc] init];
                [anotherDateFormatter setDateStyle:NSDateFormatterLongStyle];
                [anotherDateFormatter setTimeStyle:NSDateFormatterShortStyle];
                
                reformattedItem[@"Value"] = [anotherDateFormatter stringFromDate:myDate];
                
                [cleanedItem removeObjectForKey:@"$date"];
            }
            
        }

        
        NSArray *children = [self reformatJSONDict: cleanedItem];
        reformattedItem[@"Children"] = children;
        
        
        
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
        reformattedItem[@"Value"] = [NSString stringWithFormat:@"[ %@ ]", [NSNumber numberWithLong:[value count]]];

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
    NSDictionary *rObj = [item representedObject];
    
    if (rObj && [rObj objectForKey:@"Type"])
    {
        if ([[outlineView tableColumns] objectAtIndex:0] == tableColumn)
        {
            // Key
            MangoBrowserKeyCell *cell = [[MangoBrowserKeyCell alloc] init];
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

- (IBAction)runQueryButtonWasPressed:(id)sender {
    
}


@end
