//
//  RedView.m
//  RACLearning
//
//  Created by 宋法键 on 16/8/31.
//  Copyright © 2016年 songfj. All rights reserved.
//

#import "RedView.h"

@implementation RedView

- (RACSubject *)btnClickSignal {
    if (_btnClickSignal == nil) {
        _btnClickSignal = [RACSubject subject];
    }
    return _btnClickSignal;
}

- (IBAction)btnClick:(id)sender {
    [self.btnClickSignal sendNext:@"RedView按钮被点击了"];
}

- (IBAction)btnClick2:(id)sender {
    
}

@end
