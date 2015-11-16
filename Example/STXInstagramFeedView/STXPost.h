//
//  STXPost.h
//  STXDynamicTableViewExample
//
//  Created by Jesse Armand on 9/4/14.
//  Copyright (c) 2014 2359 Media Pte Ltd. All rights reserved.
//

@import Foundation;

#import "STXPostItem.h"

@interface STXPost : NSObject <STXPostItem>

@property (nonatomic, strong) UIImage *standardImage;
@property (nonatomic, strong) UIImage *lowImage;
@property (nonatomic, strong) UIImage *thumbImage;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
