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
        [self setAutoRefresh:YES];
        [self setQueryLimit:@(10)];
        self.dbData = [@[] mutableCopy];
        [[self filterPredicateEditor] addRow:self];
        
        [self addObserver:self forKeyPath:@"queryLimit" options:0 context:nil];
        
    }

    return self;
}


#pragma mark KVO

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqualTo:self])
    {
        if ([keyPath isEqualToString:@"queryLimit"])
        {
            // Trigger search again
            if ([self shouldAutoRefresh])
            {
                NSWindowController *wc = [[[self view] window] windowController];
                SEL dmSelector = NSSelectorFromString(@"dataManager");
                if ([wc respondsToSelector:dmSelector])
                {
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    MangoDataManager *dm = [wc performSelector:dmSelector];
                    #pragma clang diagnostic pop
                    [self execQueryWithDataManager:dm];
                }
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(BOOL) shouldAutoRefresh
{
    return [self autoRefresh];
}

-(void) execQueryWithDataManager: (MangoDataManager *) mgr
{
    [[self progressBar] startAnimation:self];
    [[self progressBar] setHidden: NO];
    [[[self progressBar] animator] setAlphaValue:1];
    [[self messageInfo] setStringValue: [NSString stringWithFormat:@"Loading %@", [self queryNamespace]]];
    NSDate *startDate = [NSDate date];
    NSMutableDictionary *options = [@{} mutableCopy];
    
    if (![[self queryLimit] isEqualToNumber:@(0)])
    {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * limit = [f numberFromString:[[self queryLimit] stringValue]];
        options[@"limit"] = limit;
    }
    
    NSArray *res = [[mgr ConnectionManager] queryNameSpace: [NSString stringWithFormat:@"%@", [self queryNamespace] ] withOptions: options];
    //res = [self reformatQueryResults:res];
    NSWindowController *wc = [[[self view] window] windowController];
    SEL dmSelector = NSSelectorFromString(@"dataManager");
    if ([wc respondsToSelector:dmSelector])
    {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        MangoDataManager *dm = [wc performSelector:dmSelector];
        #pragma clang diagnostic pop
        NSMutableArray *_converted = [dm convertMultipleJSONDocumentsToMango: res];
        [self setDbData:_converted];
        [[self outlineView] reloadData];
    }

    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:startDate];
    [[self progressBar] stopAnimation:self];
    [[[self progressBar] animator] setAlphaValue:0.0];
    [[self messageInfo] setStringValue: [NSString stringWithFormat:@"Loaded %@ - %ld records in %f s", [self queryNamespace], [[self dbData] count], timeInterval]];
}

#pragma mark - MangoPlugin

-(void) refreshDataFromDB: (NSString *) db withCollection: (NSString *) col andDataManager: (MangoDataManager *) mgr
{
    if ([[col stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] != 0)
    {
        [self setQueryNamespace:[NSString stringWithFormat:@"%@.%@", db, col]];
        if ([self shouldAutoRefresh])
        {
            [self execQueryWithDataManager: mgr];
        }
    }
    else
    {
        [self setQueryNamespace:@""];
        [[self messageInfo] setStringValue: @""];
        [self setDbData:[@[] mutableCopy]];
        [[self outlineView] reloadData];
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

- (IBAction)mapReduceButtonWasPressed:(id)sender
{
    [self togglePopOver:[self mapReducePopover] withSender:sender];
}

- (IBAction)filterButtonWasPressed:(id)sender
{
    [self togglePopOver:[self filterPopover] withSender:sender];
}

- (IBAction)runQueryButtonWasPressed:(id)sender
{
    NSWindowController *wc = [[[self view] window] windowController];
    SEL dmSelector = NSSelectorFromString(@"dataManager");
    if ([wc respondsToSelector:dmSelector])
    {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        MangoDataManager *dm = [wc performSelector:dmSelector];
        #pragma clang diagnostic pop
        [self execQueryWithDataManager:dm];
    }
}

- (IBAction)indicesButtonWasPressed:(id)sender
{
    [self togglePopOver:[self indicesPopover] withSender:sender];
}

-(void) togglePopOver: (NSPopover *) popover withSender: (id) sender
{
    if ([popover isShown])
    {
        [popover close];
    }
    else
    {
        [popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    }
}


-(void) setSimpleMode
{
    NSArray *subViews = [[self toolBar] subviews];
    
    for(NSView *subview in subViews)
    {
        [subview setHidden:YES];
    }
    [self setAutoRefresh:NO];
}


@end
