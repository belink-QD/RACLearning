//
//  ViewController.m
//  RACLearning
//
//  Created by 宋法键 on 16/8/26.
//  Copyright © 2016年 songfj. All rights reserved.
//

#import "ViewController.h"
#import "RedView.h"
#import "NSObject+RACKVOWrapper.h"
#import "Flag.h"
#import "NextViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountLabel;
@property (weak, nonatomic) IBOutlet UITextField *pwdLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (nonatomic) id<RACSubscriber> subscriber;
@property (weak, nonatomic) IBOutlet UITextField *txtField;
@property (weak, nonatomic) IBOutlet UILabel *txtLabel;
@property (weak, nonatomic) IBOutlet RedView *redView;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic) RACSignal *signal;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    NextViewController *next = [[NextViewController alloc] init];
//    [self presentViewController:next animated:YES completion:nil];
    
//    [self RACSequence];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[@[@"you", @"are", @"beautiful"] .rac_sequence.signal map:^id(id value) {
        return [value capitalizedString];
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
}

//RAC常用的宏
- (void)RACMacros {
    
    //1.RAC
//    [_txtField.rac_textSignal subscribeNext:^(id x) {
//        _txtLabel.text = x;
//    }];
    //用宏更简单,用来给某个对象的属性绑定一个信号，只要产生信号内容，就会把内容给属性赋值
    RAC(_txtLabel, text) = _txtField.rac_textSignal;
    
    //2.监听某个对象的某个属性
    [RACObserve(self.view, frame) subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    //3.@weakify, @strongify 防止循环引用
    @weakify(self);
    _signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSLog(@"%@", self.signal);
        return nil;
    }];
    [_signal subscribeNext:^(id x) {
        
    }];
    
    
    //4.包装元组
    RACTuple *tuple = RACTuplePack(@1, @2);
    NSLog(@"%@", tuple[0]);
    
    
}

//当一个界面有多次请求的时候，需要保证所有的请求完成才能搭建界面
- (void)lifrSelector {
    //请求第一个模块
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //请求数据AFN
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"第一个模块"];
        });
        
        return nil;
    }];
    //请求第二个模块
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //请求数据AFN
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"第二个模块"];
        });
        
        return nil;
    }];
    
    //数组存放信号
    //当数组中的所有信号都发送数据的时候才会执行方法
    //方法是有要求的，方法的参数必须与数组的信号一一对应
    [self rac_liftSelector:@selector(updateUI: and:) withSignalsFromArray:@[signal1, signal2]];
}
- (void)updateUI:(NSString *)str1 and:(NSString *)str2 {
    
    NSLog(@"两个模块加载完成--%@--%@", str1, str2);
}

- (void)RACReplace {
    //1.代替代理
    //需要传值得时候用RACSubject，不需要的时候用下面这种方法
    [[_redView rac_signalForSelector:@selector(btnClick2:)] subscribeNext:^(id x) {
        NSLog(@"红色按钮被点击了");
    }];
    
    //2.代替kvo
    [_redView rac_observeKeyPath:@"frame" options:(NSKeyValueObservingOptionNew) observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        
    }];
    
    [[_redView rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id x) {
       //x就是修改的值；
        NSLog(@"%@", x);
    }];
    
    
    //3.监听事件
    [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"按钮被点击了");
    }];
    
    //4.代替通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    
    //5.监听文本框
    [_txtField.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _redView.frame = CGRectMake(0, 0, 200, 200);
}

//NSArray NSDictionary遍历
- (void)RACSequence {
    
    NSArray *array = @[@"111", @"222", @2];
    
    //NSArray遍历
    //数组转集合
    RACSequence *sequence = array.rac_sequence;
    //把集合转化为信号
    RACSignal *signal = sequence.signal;
    //遍历数组
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    //同上
    [array.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    /*
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *mutArray = [NSMutableArray array];
    [array.rac_sequence.signal subscribeNext:^(NSDictionary *dict) {
        Flag *flag = [Flag flagWithDict:dict];
        [mutArray addObject:flag];
    }];
    
    //高级用法，代替上面
    //把集合中所有的元素映射成为一个新的对象
    NSArray *array1 = [[array.rac_sequence map:^id(NSDictionary *value) {
        
        //value 集合中的元素
        //id：返回对象就是映射的值
        return [Flag flagWithDict:value];
    }] array];
    NSLog(@"%@", array1);
    */
    
    
    
    //NSDictionary遍历
    NSDictionary *dict = @{@"account": @"name", @"name": @"xmg", @"age": @18};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *tuple) {
//        NSString *key = tuple[0];
//        NSString *value = tuple[1];
//        
//        NSLog(@"%@: %@", key, value);
        
        //或者用RAC的宏
        //参数需要穿解析出来的变量名
        RACTupleUnpack(NSString *key, NSString *value) = tuple;
        
        NSLog(@"%@: %@", key, value);
        
    } completed:^{
        NSLog(@"字典遍历完成");
    }];
    
}

//RAC集合类
- (void)RACTuple {
    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"111", @"222", @3]];
    NSString *str = tuple[0];
    NSNumber *num = tuple[2];
    
    NSLog(@"%@", num);
}

- (void)redViewTest {
    [_redView.btnClickSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}

- (void)RACReplaySubject {
    //创建信号 RACReplaySubject 是 RACSubject子类 但是可以先发送，再订阅
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    //发送信号 先保存值，然后遍历所有的订阅者去发送数据
    [subject sendNext:@"sss"];
    
    //订阅信号 遍历所有的值，然后拿到当前订阅者去发送数据
    [subject subscribeNext:^(id x) {
        NSLog(@"11---%@", x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"22---%@", x);
    }];
}

//RACSubject用法
- (void)RACSubject {
    //RACSubject 信号提供者，也可以发送信号(一个发送，多个接收)
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    //先订阅信号，不同信号订阅的方式不一样，subject仅仅是保存订阅者到数组中
    [subject subscribeNext:^(id x) {
        NSLog(@"subject1 -- %@", x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"subject2 -- %@", x);
    }];
    
    //再发送信号subject从数组遍历取出所有订阅者发送数据
    [subject sendNext:@"subject"];
}

//取消订阅信号
- (void)RACDisposable {
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //只要订阅者在，就不会自动取消订阅
        _subscriber = subscriber;
        //3.发送信号
        [subscriber sendNext:@"sss"];
        
        //默认一个信号发送数据完毕以后就会被主动取消订阅
        return [RACDisposable disposableWithBlock:^{
            //信号取消订阅就会来到这个block
            NSLog(@"信号被取消订阅");
        }];
    }];
    
    //2.订阅信号
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    //主动取消订阅
    [disposable dispose];
}

//创建信号
- (void)RACSignal {
    //    RAC使用步骤
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //didSubscribe调用，只要信号被订阅就会调用
        //didSubscribe作用：发送数据
        
        //3.发送信号
        [subscriber sendNext:@1];
        
        return nil;
    }];
    //2.订阅信号
    
    [signal subscribeNext:^(id x) {
        //nextBlock调用：只要订阅者发送数据就会调用
        //nextBlock作用：处理数据，展示到UI上
        //x 就是信号发送的内容
        
        NSLog(@"%@", x);
        
    }];
    
    //订阅者只要调用sendNext，就会执行nextBlock
    //只要信号被订阅，就会执行didSubscribe
    //前提条件是RACDynamicSignal，不同类型的订阅，处理的事情不一样
}

@end
