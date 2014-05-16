//
//  MangoFileBrowserOutlineViewController.h
//  Mango
//
//  Created by Juan Carlos Moreno on 5/15/14.
//  Copyright (c) 2014 Juan Carlos Moreno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MangoBrowserContainer.h"

@interface MangoFileBrowserCollectionViewController : NSViewController<MangoBrowserContainer>

@property NSMutableArray *dbData;

@end
