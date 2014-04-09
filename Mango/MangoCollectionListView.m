//
//  MangoCollectionList.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/8/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoCollectionListView.h"

@implementation MangoCollectionListView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.collectionListItems = @{};
        [self setDataSource:self];
        [self setDelegate:self];
    }
    return self;
}


- (void)setCollectionList:(NSArray *)cl
{
    NSMutableDictionary *result = [@{} mutableCopy];
    [self setCollectionListItems: result];
    for (NSString *cl_fullname in cl)
    {
        NSArray *fname_elements = [cl_fullname componentsSeparatedByString:@"."];
        NSUInteger length = [fname_elements count];
        NSMutableDictionary *ptr = result;
        for (int i=0; i<length; i++)
        {
            if (i == length-1)
            {
                // Last item
                [ptr setObject:@"" forKey:fname_elements[i]];
            }else
            {
                NSMutableDictionary *column = [ptr valueForKey:fname_elements[i]];
                if (column)
                {
                    ptr = column;
                }
                else
                {
                    NSMutableDictionary *value = [@{} mutableCopy];
                    [ptr setObject:value forKey:fname_elements[i]];
                    ptr = value;
                }
            }
            
        }

    }

    [self setCollectionListItems:result];
    [self reloadData];
//    NSLog(@"%@ %@", NSStringFromSelector(_cmd), result);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (!item)
    {
        return [[self collectionListItems] count];
    }
    
    NSLog(@"Querying %@", item );
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    NSLog(@"isItemExpandable %@", item );
    if (!item)
    {
        return YES;
    }
    
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd),  item );
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd),  item );
    return nil;
}

@end
