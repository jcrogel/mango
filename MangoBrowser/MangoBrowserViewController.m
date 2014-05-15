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
        [[self dataView] setDbData: [@[] mutableCopy]];
        [[self filterPredicateEditor] addRow:self];
        
        [self addObserver:self forKeyPath:@"queryLimit" options:0 context:nil];
        [self setBrowserMode: MangoBrowserDataViewMode];
        
        
    }

    return self;
}


//-(void) setD

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

-(void) setBrowserMode: (NSUInteger) browserMode
{
    if (browserMode == MangoBrowserFileViewMode)
    {
        //
    }
    else
    {
        MangoBrowserOutlineViewContainer *outlineVC = [[MangoBrowserOutlineViewContainer alloc] initWithNibName:@"MangoBrowserOutlineView" bundle:[NSBundle bundleForClass:[self class]]];
        
        CGRect newRect = [[self browserContainer] frame];
        if (![[self toolBar] isHidden])
        {
            newRect.origin.y -= 30;
        }
        else
        {
            
        }

        [[outlineVC view] setFrame:newRect];
        [[self browserContainer] addSubview:[outlineVC view]];
        [self setDataView: outlineVC];
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
        [[self dataView] setDbData:_converted];
        [[self dataView] reloadData];
    }

    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:startDate];
    [[self progressBar] stopAnimation:self];
    [[[self progressBar] animator] setAlphaValue:0.0];
    [[self messageInfo] setStringValue: [NSString stringWithFormat:@"Loaded %@ - %ld records in %f s", [self queryNamespace], [[[self dataView] dbData] count], timeInterval]];
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
        [[self dataView] setDbData:[@[] mutableCopy]];
        [[self dataView] reloadData];
        
    }
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
