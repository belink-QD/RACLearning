//
//  Flag.m
//  RACLearning
//
//  Created by 宋法键 on 16/8/31.
//  Copyright © 2016年 songfj. All rights reserved.
//

#import "Flag.h"

@implementation Flag
+ (instancetype)flagWithDict:(NSDictionary *)dict {
    Flag *flag = [[self alloc] init];
    
    [flag setValuesForKeysWithDictionary:dict];
    
    return flag;
}
@end
