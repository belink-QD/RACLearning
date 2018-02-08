//
//  NextViewController.m
//  RACLearning
//
//  Created by 宋法键 on 16/9/4.
//  Copyright © 2016年 songfj. All rights reserved.
//

#import "NextViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSObject+RACKVOWrapper.h"
#import "BindViewController.h"


@interface NextViewController ()

@end

@implementation NextViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BindViewController *bind = [[BindViewController alloc] init];
    [self presentViewController:bind animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
    
    
//    [self RACCommand];
    

    
}

//switchToLatest：获取信号中的信号发送的最新的信号
- (void)signalOfSignals {
    //高级用法
    //创建信号中的信号
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *subject = [RACSubject subject];
    RACSubject *subject1 = [RACSubject subject];
    //订阅信号
    [signalOfSignals subscribeNext:^(RACSignal *x) {
        [x subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
    }];
    //switchToLatest：获取信号中的信号发送的最新的信号
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    //发送信号
    [signalOfSignals sendNext:subject];
    [subject sendNext:@"ss"];
}

//RAC中用于处理事件的类，可以把事件如何处理，事件中的数据如何传递,包装到这个类中，他可以方便的监听事件的执行过程
- (void)RACCommand {
    //1.创建命令,
    //不能返回一个空的信号
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //input 就是execute传入的参数
        //block调用的时刻：只要执行命令的时候就会调用
        
        NSLog(@"%@", input);
        //不能返回nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [subscriber sendNext:@"执行命令产生的数据"];
            
            //当命令发送完成，一定要主动发送执行完成
            [subscriber sendCompleted];
            
            return nil;
        }];
        
    }];
    
    //监听事件有没有完成
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue]) {
            NSLog(@"%@ 正在执行", x);
        } else {
            NSLog(@"%@ 执行完成/没有执行", x);
        }
        
    }];
    
    
    //下面的这些方法必须放在[command execute:@2]; 前面，不然不会执行
    //如何拿到执行命令中产生的数据
    //订阅命令内部的信号
    
    /*
    //1.方式一：直接订阅执行命令返回的信号
    RACSignal *signal = [command execute:@"2"];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    */
    
    /*
    //2.方式二
    //不许要在执行命令前被订阅
    //订阅信号
    //executionSignals:信号源，信号中的信号。发送数据几句是信号
    [command.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
        NSLog(@"%@", x);
    }];
    
    
    //2.执行命令
    [command execute:@2];
    */
    
    //switchToLatest:获取最新发送的信号，只能用于信号中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [command execute:@2];
    
    
}

// RACMulticastConnection 用于当一个信号被多次调用的时候，为了保证创建信号时，避免多次调用创建信号中的block造成副作用，可以使用这个类处理
- (void)RACMulticastConnection {
    //每次订阅都不要都请求一次，指向请求一次，每次订阅只拿到数据
    //不管订阅多少次信号，就会请求一次
    
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"发送热门模块的请求");
        
        [subscriber sendNext:@22];
        
        return nil;
    }];
    //2.把信号转化成链接类
    RACMulticastConnection *connection = [signal publish];
//    [signal multicast:signal]; //这个方法也可以
    
    //3.订阅链接类的信号 //NSLog(@"发送热门模块的请求") 只会发送一次，而@22会发送多次
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"1.%@", x);
    }];
    
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"2.%@", x);
    }];
    
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"3.%@", x);
    }];
    
    //4.链接
    [connection connect];
    
}

- (void)RACSignal {
    //    RACMulticastConnection 用于当一个信号被多次调用的时候，为了保证创建信号时，避免多次调用创建信号中的block造成副作用，可以使用这个类处理
    //例如，下面这个，每次请求都会打印“发送热门模块的请求”，而有时只想要@“11”这个值
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送热门模块的请求");
        [subscriber sendNext:@"11"];
        return nil;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"1.%@", x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"2.%@", x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"3.%@", x);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
