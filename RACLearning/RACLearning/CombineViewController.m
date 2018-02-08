//
//  CombineViewController.m
//  RACLearning
//
//  Created by 宋法键 on 16/9/5.
//  Copyright © 2016年 songfj. All rights reserved.
//

#import "CombineViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CombineViewController ()

@end

@implementation CombineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self skip];
}

//跳过几个信号
- (void)skip {
    RACSubject *subject = [RACSubject subject];
    
    [[subject skip:1] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
}

//如果当前的值跟上一次相同，就不会被订阅到
- (void)distinctUntilChanged {
    RACSubject *subject = [RACSubject subject];
    
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@1];
}

//获取几次信号
- (void)take {
    RACSubject *subject = [RACSubject subject];
    RACSubject *subject1 =[RACSubject subject];
    //取前面几个值
    [[subject take:1] subscribeNext:^(id x) {
        NSLog(@"take:%@", x);
    }];
    
    //取后面几个值（必须发送 sendCompleted）
    [[subject takeLast:1] subscribeNext:^(id x) {
        NSLog(@"takeLast:%@", x);
    }];
    
    //只要传入的信号发送完成,或者发送任意数据（发送错误不行），就不会接收到原信号的内容
    [[subject takeUntil:subject1] subscribeNext:^(id x) {
        NSLog(@"takeUntil:%@", x);
    }];
    
    [subject sendNext:@"1"];//会发送
    [subject1 sendCompleted];
    [subject sendNext:@"13"];//不会发送
    [subject sendCompleted];
}

//忽略
- (void)ignore {
    RACSubject *subject = [RACSubject subject];
    
    //忽略信号
    RACSignal *ignoreSignal = [subject ignore:@"1"];
    
    //订阅
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [subject sendNext:@"1"];//会被忽略
    [subject sendNext:@"13"];
}

//过滤
- (void)filter {
    UITextField *txt1 = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [self.view addSubview:txt1];
    
    [[txt1.rac_textSignal filter:^BOOL(id value) {
        return [value length] > 5;
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}

//combine来组合信号
- (void)combineAndReduce {
    UITextField *txt1 = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [self.view addSubview:txt1];
    UITextField *txt2 = [[UITextField alloc] initWithFrame:CGRectMake(100, 150, 100, 40)];
    [self.view addSubview:txt2];
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = CGRectMake(100, 210, 100, 40);
    btn.backgroundColor = [UIColor orangeColor];
    btn.enabled = NO;
    [self.view addSubview:btn];
    
    
    //需求：只有两个输入框都有输入的时候按钮才能点击
    //组合 combine:组合， reduce：聚合
    //reduceBlock参数：跟组合信号有关，一一对应
    RACSignal *combineSignal = [RACSignal combineLatest:@[txt1.rac_textSignal, txt2.rac_textSignal] reduce:^id(NSString *account, NSString *pwd){
        
        NSLog(@"account:%@ -- pwd:%@", account, pwd);
        //聚的值就是组合信号的内容
        //只要原信号发送内容就会调用，组合成一个系的值
        
        return @(account.length && pwd.length);
    }];

    //订阅
//    [signal subscribeNext:^(id x) {
//        btn.enabled = [x boolValue];
//    }];
    
    //下面方法代替上面的方法
    RAC(btn, enabled) = combineSignal;
    
}

//zipWith来组合信号 :一个界面多个请求的时候，等多个秦秋完成了才能更新UI，这时候用zipWith来组合信号
- (void)zipWith {
    //信号A
    RACSubject *signalA = [RACSubject subject];
    //信号B
    RACSubject *signalB = [RACSubject subject];
    
    //信号C
    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送了C的请求");
        
        [subscriber sendNext:@"C"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //组合信号 结果与发送顺序无关，与组合顺序有关
    RACSignal *zipSignal = [[signalA zipWith:signalB] zipWith:signalC];
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [signalB sendNext:@"B"];
    [signalA sendNext:@"A"];
}

//merge 来组合信号，任意一个信号请求完成，都会被订阅到，无顺序
- (void)merge {
    //信号A
    RACSubject *signalA = [RACSubject subject];
    //信号B
    RACSubject *signalB = [RACSubject subject];
    
    //信号C
    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送了C的请求");
        
        [subscriber sendNext:@"C的数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //组合信号 merge
    RACSignal *mergeSignal = [[signalA merge:signalB] merge:signalC];
    
    [mergeSignal subscribeNext:^(id x) {
        //任意一个信号发送的内容都会来到这里
        NSLog(@"%@", x);
    }];
    
    
    [signalB sendNext:@"B部分"];
    [signalA sendNext:@"A部分"];
    
}

//then来组合信号
- (void)then {
    //信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送了A的请求");
        
        [subscriber sendNext:@"A的数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    //信号B
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送了B的请求");
        
        [subscriber sendNext:@"B的数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //信号C
    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送了C的请求");
        
        [subscriber sendNext:@"C的数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //组合信号 then 会忽略上面信号的值，拿到下面部分的值
    RACSignal *thenSignal = [[signalA then:^RACSignal *{
        //返回的信号就是要组合的信号
        return signalB;
    }] then:^RACSignal *{
        return signalC;
    }];
    //订阅
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];

}

//RAC组合信号
- (void)concat {
    
    //信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送了A的请求");
        
        [subscriber sendNext:@"A的数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    //信号B
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送了B的请求");
        
        [subscriber sendNext:@"B的数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //信号C
    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送了C的请求");
        
        [subscriber sendNext:@"C的数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //按照顺序去请求
    //创建组合信号
    RACSignal *concatSignal = [[signalA concat:signalB] concat:signalC];
    //订阅组合信号
    [concatSignal subscribeNext:^(id x) {
        //既能拿到A的信号值，又能拿到B信号的值，掐提示，每次都要发送completed
        NSLog(@"%@", x);
    }];
}

@end
