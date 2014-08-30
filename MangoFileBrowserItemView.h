//
//  MangoFileBrowserItemView.h
//  Mango
//
//  Created by Juan Carlos Moreno on 8/29/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import "MangoFileBrowserCollectionView.h"
#import <Cocoa/Cocoa.h>

@interface MangoFileBrowserItemView : NSBox

@property (assign) BOOL selected;
@property (nonatomic) MangoFileBrowserCollectionView *collectionView;

@end
