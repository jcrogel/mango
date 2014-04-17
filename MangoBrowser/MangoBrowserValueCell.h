//
//  MangoBrowserValueCell.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/16/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MangoBrowserValueCell : NSTextFieldCell
{
@private
    BOOL mouseInside;
    NSTrackingArea *trackingArea;
}

@property NSString *dataType;


@end
