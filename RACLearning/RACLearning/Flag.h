//
//  Flag.h
//  RACLearning
//
//  Created by 宋法键 on 16/8/31.
//  Copyright © 2016年 songfj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Flag : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *icon;

+ (instancetype)flagWithDict:(NSDictionary *)dict;

@end
