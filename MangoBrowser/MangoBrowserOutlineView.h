//
//  MangoBrowserOutlineView.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/17/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSCell+TrackingCell.h"

@interface MangoBrowserOutlineView : NSOutlineView
{
@private
    NSInteger iMouseRow, iMouseCol;
    NSCell *iMouseCell;
}

@end
