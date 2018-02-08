//
//  RedView.h
//  RACLearning
//
//  Created by 宋法键 on 16/8/31.
//  Copyright © 2016年 songfj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RedView : UIView

@property (nonatomic) RACSubject *btnClickSignal;

@end
