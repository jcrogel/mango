//
//  MangoBrowserCell.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/16/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MangoBrowserCell : NSTextFieldCell
{
@private

    NSTrackingArea *trackingArea;
@protected
    BOOL mouseInside;
}

@property NSString *dataType;

-(void)rightClickedEvent: (NSEvent *)theEvent withSender: (id)sender;

@end
