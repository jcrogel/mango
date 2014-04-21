//
//  MangoPluginTabItem.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/20/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MMTabBarView/MMTabBarItem.h>

@interface MangoPluginTabItem : NSObject<MMTabBarItem>

@property (copy)   NSString     *title;
@property (retain) NSImage      *icon;
@property (retain) NSImage      *largeImage;
@property (assign) NSInteger    objectCount;
@property (retain) NSColor      *objectCountColor;

@property (assign) BOOL isProcessing;
@property (assign) BOOL isEdited;
@property (assign) BOOL hasCloseButton;



@end
