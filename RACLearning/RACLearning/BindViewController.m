//
//  BindViewController.m
//  RACLearning
//
//  Created by 宋法键 on 16/9/4.
//  Copyright © 2016年 songfj. All rights reserved.
//

#import "BindViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSObject+RACKVOWrapper.h"
#import "CombineViewController.h"
#import <ReactiveCocoa/RACReturnSignal.h>

@interface BindViewController ()

@end

@implementation BindViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CombineViewController *com = [[CombineViewController alloc] init];
    [self presentViewController:com animated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
//    [self signalOfSignals];
}

- (void)signalOfSignals {
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *subject = [RACSubject subject];
    
    //订阅信号
//    [signalOfSignals subscribeNext:^(id x) {
//        [x subscribeNext:^(id x) {
//            NSLog(@"%@", x);
//        }];
//    }];
    /*
    RACSignal *bindSignal = [signalOfSignals flattenMap:^RACStream *(id value) {
        return value;
    }];
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
     */
    
    //上面的写法太麻烦，开发中用下面的写法
    [[signalOfSignals flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    //发送信号
    [signalOfSignals sendNext:subject];
    [subject sendNext:@"12"];
}

//
- (void)RACMap {
    //创建信号
    RACSubject *subject = [RACSubject subject];
    
    //绑定 返回任意想要的类型
    RACSignal *bindSignal = [subject map:^id(id value) {
        return @"111";
    }];
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [subject sendNext:@"aa"];
}

//一般用于信号中的信号
- (void)RACFlattenMap {
    //创建信号
    RACSubject *subject = [RACSubject subject];
    
    //绑定 返回的RACStream *类型
    RACSignal *bindSignal = [subject flattenMap:^RACStream *(id value) {
        //value:原信号发送的内容
        //返回的信号，就是要包装的值
        return [RACReturnSignal return: [NSString stringWithFormat:@"包装的%@", value]];
    }];
    //订阅信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    //发送数据
    [subject sendNext:@"ss"];
}

//绑定
- (void)RACBind {
    //使用bind对原信号进行处理，然后返回
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    //2.hock绑定信号
    RACSignal *bindSignal = [subject bind:^RACStreamBindBlock{
        return ^RACSignal *(id value, BOOL *stop) {
            //block调用：只要原信号发送数据，就会调用block
            //value：原信号发送的内容
            NSLog(@"%@", value);
            //返回信号，不能传nil，如果想要传nil，用下面方法代替
            value = [NSString stringWithFormat:@"处理以后的信号+%@", value];
            return [RACReturnSignal return:value];
        };
    }];
    
    //3.订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    //4.发送数据
    [subject sendNext:@"222"];
}



@end
