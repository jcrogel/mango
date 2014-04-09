//
//  MangoCollectionList.h
//  Mango
//
//  Created by Juan Carlos Moreno on 4/8/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MangoCollectionListView : NSOutlineView<NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic) NSDictionary *collectionListItems;
- (void)setCollectionList:(NSArray *)cl;

@end
