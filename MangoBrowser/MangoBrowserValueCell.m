//
//  MangoBrowserValueCell.m
//  Mango
//
//  Created by Juan Carlos Moreno on 4/16/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoBrowserValueCell.h"

@implementation MangoBrowserValueCell



- (void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if ([self dataType])
    {
        if ([[self dataType] isEqualToString:@"ObjectID"])
        {
            [self setTitle: [NSString stringWithFormat:@"ObjectID(%@)", [self title]]];
        }
        if ([[self dataType] isEqualToString:@"Array"])
        {
            //color = ARRAY_COLOR.CGColor;
        }
        if ([[self dataType] isEqualToString:@"String"])
        {
            //color = STRING_COLOR.CGColor;
        }
        if ([[self dataType] isEqualToString:@"Bool"])
        {
            //color = BOOL_COLOR.CGColor;
            if ([[self title] isEqualToString:@"0"])
            {
                [self setTitle:@"False"];
            }
            else
            {
                [self setTitle:@"True"];
            }
        }
        if ([[self dataType] isEqualToString:@"Null"])
        {
            //color = NULL_COLOR.CGColor;
            [self setTitle:@"null"];
        }
        if ([[self dataType] isEqualToString:@"Number"])
        {
            //color = NUMBER_COLOR.CGColor;
        }
    }

	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
