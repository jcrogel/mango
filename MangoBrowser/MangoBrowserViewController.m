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
        //res = [self reformatQueryResults:res];
        NSWindowController *wc = [[[self view] window] windowController];
        SEL dmSelector = NSSelectorFromString(@"dataManager");
        if ([wc respondsToSelector:dmSelector])
        {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            MangoDataManager *dm = [wc performSelector:dmSelector];
            #pragma clang diagnostic pop
            res = [dm convertMultipleJSONDocumentsToMango: res];
            [self setDbData:res];
            [[self outlineView] reloadData];
        }
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        [[self progressBar] stopAnimation:self];
        [[[self progressBar] animator] setAlphaValue:0.0];
        [[self messageInfo] setStringValue: [NSString stringWithFormat:@"Loaded %@.%@ in %f", db, col, timeInterval]];
    }
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

- (IBAction)indicesButtonWasPressed:(id)sender {
    if ([[self fieldPopover] isShown])
    {
        [[self fieldPopover] close];
    }
    else
    {
        [[self fieldPopover] showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    }
    
}


@end
