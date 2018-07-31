//
//  RTRACOperation.m
//  PracticeProject
//
//  Created by lynn on 2017/12/5.
//  Copyright © 2017年 lynn. All rights reserved.
//

#import "RACOperation.h"

@implementation RACOperation

#pragma mark - RAC操作 self
- (void)merge_concat_then_combineLatest
{
    // merge:        任意信号有新值都会转发
    // concat:       前面的信号sendComplete之后才开始转发后面的信号内容, 所有信号发送的值都会转发
    // then:         前面的信号sendComplete之后才开始转发后面的信号内容, 但是只转发then后面拼接的信号内容.
    // combineLatest:两个信号都发送过值才会转发, 并且之后任意信号有新值都会转发
    // zipWith:   每次两个信号都发送过值才会转发,并zip
    
    RACSignal *A = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"a"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{}];
    }];
    
    RACSignal *B = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"b"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{}];
    }];
    
    //    [[A concat:B] subscribeNext:^(id x) {
    //        NSLog(@"%@",x);
    //    }];
    
    [[A then:^RACSignal *{
        return B;
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}

- (void)scanWithStart
{
    NSArray *arr = [@"0 1 2 3 4" componentsSeparatedByString:@" "];
    
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [arr.rac_sequence.signal subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }];
    
    // 注意: 区别于aggregateWithStart, scanWithStart会转发每次运算结果, aggregateWithStart只转发最终结果.
    [[s scanWithStart:@"wfl" reduce:^id(id running, id next) {
        NSLog(@"running = %@, next = %@",running,next);
        return [NSString stringWithFormat:@"%@-%@",running,next];
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //    打印结果:
    //    running = wfl, next = 0
    //    wfl-0
    //    running = wfl-0, next = 1
    //    wfl-0-1
    //    running = wfl-0-1, next = 2
    //    wfl-0-1-2
    //    running = wfl-0-1-2, next = 3
    //    wfl-0-1-2-3
    //    running = wfl-0-1-2-3, next = 4
    //    wfl-0-1-2-3-4
}

- (void)aggregateWithStart
{
    NSArray *arr = [@"0 1 2 3 4" componentsSeparatedByString:@" "];
    
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [arr.rac_sequence.signal subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }];
    
    // aggregateWithStart用于从提供的初始值开始依次取两个值进行运算
    // 相当于python/swift中的reduce操作: (((("wfl" + "1") + "2") + "3") + "4").
    // 注意: 所有的值都做完运算后, 最终返回一个最终的结果.
    [[s aggregateWithStart:@"wfl" reduce:^id(id running, id next) {
        NSLog(@"running = %@, next = %@",running,next);
        return [NSString stringWithFormat:@"%@-%@",running,next];
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //    打印结果:
    //     running = wfl, next = 0
    //     running = wfl-0, next = 1
    //     running = wfl-0-1, next = 2
    //     running = wfl-0-1-2, next = 3
    //     running = wfl-0-1-2-3, next = 4
    //     wfl-0-1-2-3-4
}

- (void)collect
{
    NSArray *arr = [@"0 1 2 3 4" componentsSeparatedByString:@" "];
    
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [arr.rac_sequence.signal subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }];
    
    // collect用于将接受到的值组合成可变数组NSMutableArray
    [[s collect] subscribeNext:^(id x) {
        NSLog(@"===%@",[x class]);
    }];
}

- (void)throttle
{
    NSArray *arr = [@"0 1 1 1 2 3 3 4" componentsSeparatedByString:@" "];
    
    __block NSInteger delayTime = 0;
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [arr.rac_sequence.signal subscribeNext:^(id x) {
            
            delayTime += arc4random()%2 + 1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSLog(@"=================%@",x);
                [subscriber sendNext:x];
            });
        } completed:^{
            //            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }];
    
    // 1.throttle用于保证接收到的 所有相邻的信号之前的时长大于interval这个时间 才会被接收, 并且接收的是最新的信号.
    // 必须注意的是这个interval*会在每次接收到信号后重置*, 所以throttle应该是用在防止在单位时间内重复接收信号.
    // 如果interval时间内不接收任何信号内容, 过了这个时间, 获取最后发送的信号内容发出.
    // 感觉不适合用于防止按钮重复点击. 因为从1可以第一次信号并不会被订阅, 就是说点了一次,interval时间后再点一次, 只有后面那次才起作用.
    [[s throttle:2] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    
    /*
     RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
     [arr.rac_sequence.signal subscribeNext:^(id x) {
     
     // 这里我想延迟执行sendNext, 但是这样写结果就是所有的sendNext还是几乎一起执行, 只是整体上推迟了1s.
     // 跟delay一样的效果...
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     [subscriber sendNext:x];
     });
     
     // currentThead ==== <NSThread: 0x60000027d280>{number = 3, name = (null)}
     //            NSLog(@"currentThead ==== %@",[NSThread currentThread]);
     } completed:^{
     
     NSLog(@"===========completed================");
     // 注意因为订阅arr.rac_sequence.signal(相当于遍历)是在子线程进行的, 如果在过程中搞了个延迟操作(延迟sendNext),在订阅的block中会收不到消息. 原因就是下面这句sendCompleted在sendNext(延迟执行)之前已经执行了. 所以下面这句必须注释掉.
     //            [subscriber sendCompleted];
     }];
     return [RACDisposable disposableWithBlock:^{}];
     }];
     
     [s subscribeNext:^(id x) {
     NSLog(@"%@",x);
     }];
     
     //    [[s throttle:2] subscribeNext:^(id x) {
     //        NSLog(@"%@",x);
     //    }];
     
     // distinctUntilChanged用于信号发生变化时才会发送, 过滤重复信号
     //    [[s distinctUntilChanged] subscribeNext:^(id x) {
     //        NSLog(@"%@",x);
     //    }];
     
     */
}

- (void)retry
{
    NSArray *arr = [@"0 1 2 3 4 5 6 7 8" componentsSeparatedByString:@" "];
    
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"subscriber ===== %@",subscriber);
        
        [[arr.rac_sequence.signal map:^id(NSNumber *value) {
            if (value.integerValue == 3) {
                [subscriber sendError:[NSError errorWithDomain:@"error" code:0001 userInfo:nil]];
            }
            return value;
        }] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return [RACDisposable disposableWithBlock:^{ }];
    }];
    
    // retry慎用, 用了会遇到错误就会重复订阅, subscriber ===== 会重复打印.
    [[s retry] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [s subscribeError:^(NSError *error) {
        NSLog(@"error ====== %@",error);
    }];
}

- (void)not
{
    NSArray *arr = [@"0 1 2 3 4 5 6 7 8" componentsSeparatedByString:@" "];
    
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [arr.rac_sequence.signal subscribeNext:^(NSString *x) {
            [subscriber sendNext:x.numberValue];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }];
    
    // startWith以xxx开始, 如果有多个值需要放在前面不妨直接用'concat'
    // not只针对NSNumber, 取反操作, 非@0变@0, @0变@1
    [[[s startWith:@0] not] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)connection
{
    NSArray *arr = [@"1 2 3 4 5 6 7 8" componentsSeparatedByString:@" "];
    
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"=====================%@",subscriber);
        
        [arr.rac_sequence.signal subscribeNext:^(id x) {
            [subscriber sendNext:x];
        } completed:^{
            [subscriber sendCompleted];
        }];
        
        return [RACDisposable disposableWithBlock:^{}];
    }];
    
    RACMulticastConnection *connection = [s publish];
    
    // 注意必须是对connection.signal进行订阅, 如果还去订阅s那connection就没意义了
    // 订阅coneection.subject
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // active, 这里才会真正去订阅s(不会有副作用的原因), 并将subject作为subscriber传进去, 由subject转发内容.
    [connection connect];
    
    // RACMulticastConnection通过利用subject可以先订阅后发送值来完成消除副作用
}

- (void)take {
    NSArray *arr = [@"1 2 3 4 5 6 7 8" componentsSeparatedByString:@" "];
    
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"=====================%@",subscriber);
        
        [arr.rac_sequence.signal subscribeNext:^(id x) {
            [subscriber sendNext:x];
            NSLog(@"+++++++++++++%@",x);
            
        } completed:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }];
    
    //    [[s take:3] subscribeNext:^(id x) {
    //        NSLog(@"%@",x);
    //    }];
    
    [[s takeUntilBlock:^BOOL(id x) {
        return [x isEqualToString:@"5"];
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [[s takeLast:2] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //    [s subscribeNext:^(id x) {
    //        NSLog(@"+++++++++++++%@",x);
    //    }];
}

- (void)flattenMap
{
    NSArray *arr = [@"1 2 3 4 5 6" componentsSeparatedByString:@" "];
    
    RACSignal *s = [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [arr.rac_sequence.signal subscribeNext:^(id x) {
            [subscriber sendNext:[RACSignal return:x]];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }] flattenMap:^RACStream *(id value) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [value subscribeNext:^(id x) {
                [subscriber sendNext:x];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }] ignore:@"1"] ignoreValues];
    
    [s subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)filter {
    
    NSArray *arr = [@"1 2 3 4 5 6" componentsSeparatedByString:@" "];
    
    RACSignal *s = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [arr.rac_sequence.signal subscribeNext:^(id x) {
            [subscriber sendNext:[RACSignal return:x]];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{}];
    }] filter:^BOOL(NSString *value) {
        //        return value.integerValue % 2 == 0;
        return YES;
    }] flatten:0];
    
    [s subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - other's

-(void)createSignalOperation
{
    RACSignal *signal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"Disposable");
        }];
    }];
    
    //filter过滤
    [[signal filter:^BOOL(id value) {
        if ([value isEqualToString:@"2"]) {
            return YES;
        }
        return NO;
    }] subscribeNext:^(id x) {
        NSLog(@"当前的值为：%@",x);
    }];
    
    [[[signal filter:^BOOL(id value) {
        if ([value isEqualToString:@"bac"]) {
            return NO;
        }
        return YES;
    }] map:^id(NSString *value) {
        return @(value.length);
    }] subscribeNext:^(NSNumber *x) {
        NSLog(@"当前的位数为：%ld",[x integerValue]);
    }];
    
    //flattenMap
    [[signal flattenMap:^RACStream *(id value) {
        return [RACSignal return:[NSString stringWithFormat:@"当前输出为：%@",value]];
    }] subscribeNext:^(id x) {
        NSLog(@"flattenMap中执行：%@",x);
    }];
    //    输出：
    //    flattenMap中执行：当前输出为：1
    //    flattenMap中执行：当前输出为：3
    //    flattenMap中执行：当前输出为：15
    //    flattenMap中执行：当前输出为：wujy
    
    //    FlatternMap和Map的区别
    //    1.FlatternMap中的Block返回信号。
    //    2.Map中的Block返回对象。
    //    3.开发中，如果信号发出的值不是信号，映射一般使用Map
    //    4.开发中，如果信号发出的值是信号，映射一般使用FlatternMap。
    
    
    //ignore 忽略某个值
    [[signal ignore:@"3"] subscribeNext:^(id x) {
        NSLog(@"当前的值为：%@",x);
    }];
    //输出：当前的值为：1  当前的值为：15  当前的值为：wujy   执行清理
    
    
    //ignoreValues 这个比较极端，忽略所有值，只关心Signal结束，也就是只取Comletion和Error两个消息，中间所有值都丢弃
    [[signal ignoreValues] subscribeNext:^(id x) {
        //它是没机会执行  因为ignoreValues已经忽略所有的next值
        NSLog(@"ignoreValues当前值：%@",x);
    } error:^(NSError *error) {
        NSLog(@"ignoreValues error");
    } completed:^{
        NSLog(@"ignoreValues completed");
    }];
    //    输出
    //    ignoreValues completed
    
    
    
    //take:从开始一共取N次的信号
    [[signal take:1] subscribeNext:^(id x) {
        NSLog(@"take 获取的值：%@",x);
    }];
    //输出：take 获取的值：1
    
    
    //takeUntilBlock 对于每个next值，运行block，当block返回YES时停止取值
    [[signal takeUntilBlock:^BOOL(NSString *x) {
        if ([x isEqualToString:@"15"]) {
            return YES;
        }
        return NO;
    }] subscribeNext:^(id x) {
        NSLog(@"takeUntilBlock 获取的值：%@",x);
    }];
    //    输出
    //    takeUntilBlock 获取的值：1
    //    takeUntilBlock 获取的值：3
    
    
    
    //takeLast 取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号
    [[signal takeLast:1] subscribeNext:^(id x) {
        NSLog(@"takeLast 获取的值：%@",x);
    }];
    //输出：takeLast 获取的值：wujy
    
    
    //skip 跳过几个信号,不接受
    [[signal skip:2] subscribeNext:^(id x) {
        NSLog(@"skip 获取的值：%@",x);
    }];
    //输出：skip 获取的值：15    skip 获取的值：wujy
    
    
    //skipUntilBlock 同理，一直跳，直到block为YES
    [[signal skipUntilBlock:^BOOL(NSString *x) {
        if ([x isEqualToString:@"15"]) {
            return YES;
        }
        return NO;
    }] subscribeNext:^(id x) {
        NSLog(@"skipUntilBlock 获取的值：%@",x);
    }];
    //    输出
    //    skipUntilBlock 获取的值：15
    //    skipUntilBlock 获取的值：wujy
    
    
    
    //skipWhileBlock  一直跳，直到block为NO
    [[signal skipWhileBlock:^BOOL(NSString *x) {
        if ([x isEqualToString:@"15"]) {
            return NO;
        }
        return YES;
    }] subscribeNext:^(id x) {
        NSLog(@"skipWhileBlock 获取的值：%@",x);
    }];
    //    输出
    //    skipWhileBlock 获取的值：15
    //    skipWhileBlock 获取的值：wujy
    
    
    //not
    RACSignal *curSignal=[RACSignal return:@(NO)];
    
    [[curSignal not] subscribeNext:^(NSNumber *x) {
        NSLog(@"not 获取的值：%d",[x intValue]);
    }];
    //    输出
    //    not 获取的值：1
    
    
    //startWith 起始位置增加相应的元素
    RACSignal *addStartSignal=[RACSignal return:@"123"];
    [[addStartSignal startWith:@"345"] subscribeNext:^(id x) {
        NSLog(@"startWith增加的值操作 %@",x);
    }];
    //    输出
    //    startWith增加的值操作 345
    //    startWith增加的值操作 123
    
    
    
    //reduceEach 聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
    RACSignal *aSignal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:RACTuplePack(@1,@4)];
        [subscriber sendNext:RACTuplePack(@2,@3)];
        [subscriber sendNext:RACTuplePack(@5,@2)];
        return nil;
    }];
    
    [[aSignal reduceEach:^id(NSNumber *first,NSNumber *secnod){
        return @([first integerValue]+[secnod integerValue]);
    }] subscribeNext:^(NSNumber *x) {
        NSLog(@"reduceEach当前的值：%ld",[x integerValue]);
    }];
    //    输出
    //    reduceEach当前的值：5
    //    reduceEach当前的值：5
    //    reduceEach当前的值：7
}


-(void)createTimeSignal
{
    //设置定时启用，类似于NSTimer，这里需设置take方式 interval 定时：每隔一段时间发出信号  take:从开始一共取N次的信号
    [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] take:5]subscribeNext:^(id x) {
        NSLog(@"interval-take :吃药");
    }];
    //    输出(每隔一秒执行一句)
    //    interval-take :吃药
    //    interval-take :吃药
    //    interval-take :吃药
    //    interval-take :吃药
    //    interval-take :吃药
    
    
    //超时操作  timeout 超时  delay 延迟
    [[[RACSignal createSignal:^RACDisposable *(id subscriber) {
        [[[RACSignal createSignal:^RACDisposable *(id subscriber) {
            NSLog(@"我快到了");
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
            //延迟2秒后执行next事件
        }] delay:2] subscribeNext:^(id x) {
            NSLog(@"我到了");
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }] timeout:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeError:^(NSError *error) {
        NSLog(@"你再不来，我走了");
    }];
    
    //输出
    //我快到了
    //你再不来，我走了
    //我到了
}


-(void)createSignalOther
{
    //1:retry
    __block int i = 0;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"i = %d",i);
        if (i == 5) {
            [subscriber sendNext:@"i == 2"];
        }else{
            i ++;
            [subscriber sendError:nil];
        }
        return nil;
        //当发送的是error时可以retry重新执行
    }] retry] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //    输出：
    //    i = 0
    //    i = 1
    //    i = 2
    //    i = 3
    //    i = 4
    //    i = 5
    //    i == 2
    //    说明：若发送的是error则可以使用retry来尝试重新刺激信号  retry重试 ：只要失败，就会重新执行创建信号中的block,直到成功.
    
    
    //2:takeUntil
    //创建一个信号
    [[[RACSignal createSignal:^RACDisposable *(id subscriber) {
        //创建一个定时信号，每隔1秒刺激一次信号
        [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            [subscriber sendNext:@"直到世界的尽头才能把我们分开"];
        }];
        return nil;
        //直到此情况下停止刺激信号
    }] takeUntil:[RACSignal createSignal:^RACDisposable *(id subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"世界的尽头到了");
            [subscriber sendNext:@"世界的尽头到了"];
        });
        return nil;
    }]] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    //输出：
    //    直到世界的尽头才能把我们分开
    //    直到世界的尽头才能把我们分开
    //    直到世界的尽头才能把我们分开
    //    世界的尽头到了
    //    说明：takeUntil：这样当某个条件达到后，就可以停止定时器了  onScheduler:[RACScheduler mainThreadScheduler]则是在主线程上运行
    
    
    //3：doNext doCompleted执行时间   doNext: 执行Next之前，会先执行这个Block  doCompleted: 执行sendCompleted之前，会先执行这个Block
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"执行sendNext"];
        NSLog(@"执行sendNext");
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id x) {
        NSLog(@"执行doNext");
    }] doCompleted:^{
        NSLog(@"执行doCompleted");
    }] subscribeNext:^(id x) {
        NSLog(@"执行subscribeNext");
    }];
    
    //    输出
    //    执行doNext
    //    执行subscribeNext
    //    执行sendNext
    //    执行doCompleted
    
    
    //replay 重放 当一个信号被多次订阅,反复播放内容
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        
        return nil;
    }] replay];
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"replay 第一个订阅者%@",x);
        
    }];
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"replay 第二个订阅者%@",x);
        
    }];
    //    输出
    //    replay 第一个订阅者1
    //    replay 第一个订阅者2
    //    replay 第二个订阅者1
    //    replay 第二个订阅者2
    
    
    //throttle节流:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。
    RACSubject *throttleSignal = [RACSubject subject];
    [throttleSignal sendNext:@"throttle a"];
    // 节流，在一定时间（4秒）内，不接收任何信号内容，过了这个时间（1秒）获取最后发送的信号内容发出。
    [[throttleSignal throttle:4] subscribeNext:^(id x) {
        NSLog(@"throttleSignal:%@",x);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"世界的尽头到了");
        [throttleSignal sendNext:@"throttle b"];
        [throttleSignal sendNext:@"throttle c"];
    });
    //输出：throttleSignal:throttle c
}


-(void)createMergeSignal
{
    RACSignal *aSignal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"3"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"aSignal清理了");
        }];
    }];
    
    RACSignal *bSignal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"7"];
        [subscriber sendNext:@"9"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"bSignal清理了");
        }];
    }];
    
    //1.1 combineLatest用法 将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号
    RACSignal *combineSignal = [aSignal combineLatestWith:bSignal];
    
    [combineSignal subscribeNext:^(id x) {
        
        NSLog(@"combineSignal为:%@",x);
    }];
    //输出
    //    combineSignal为:<RACTuple: 0x600000015c30> (
    //                                               3,
    //                                               7
    //                                               )
    //    combineSignal为:<RACTuple: 0x600000015cb0> (
    //                                                                                                  3,
    //                                                                                                  9
    //                                                                                                  )
    
    
    //1.2：combineLatest用法 reduce聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
    //产生的最新的值聚合在一起，并生成一个新的信号 aSignal只有最新值  还有数组个数对应参数的个数
    RACSignal *combineReduceSignal=[RACSignal combineLatest:@[aSignal,bSignal] reduce:^id(NSString *aItem,NSString *bItem){
        return [NSString stringWithFormat:@"%@-%@",aItem,bItem];
    }];
    
    [combineReduceSignal subscribeNext:^(id x) {
        NSLog(@"合并后combineSignal的值：%@",x);
    }];
    //输出：aSignal清理了   合并后combineSignal的值：3-7    合并后combineSignal的值：3-9   bSignal清理了
    //说明：从结果可以看出此种合并会将第一个信号中最后一个sendnext与后面信号的所有sendnext结合起来作为一个数组，而next触发次数以bSignal中的next次数为主
    
    
    
    
    //2：then用法
    //用于连接两个信号，当第一个信号完成，才会连接then返回的信号
    RACSignal *thenSignal=[aSignal then:^RACSignal *{
        return bSignal;
    }];
    
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"thenSignal的值：%@",x);
    }];
    //输出  thenSignal的值：7   thenSignal的值：9   bSignal清理了  aSignal清理了
    
    
    //then实例
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"第一步");
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"第二步");
            [subscriber sendCompleted];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"第三步");
            return nil;
        }];
    }] subscribeCompleted:^{
        NSLog(@"完成");
    }];
    //输出：第一步   第二步  第三步
    //说明：then的用法要跟上面这样使用，它会在RACSignal里面就执行
    
    
    //collect 会把内容合并成一个数组  也就是元组
    RACSignal *arraySignal=[aSignal collect];
    [arraySignal subscribeNext:^(id x) {
        NSLog(@"collect 显示的值%@",x);
    }];
    //    输出
    //    collect 显示的值(
    //                 1,
    //                 3
    //                 )
    
    
    
    RACSignal *operateSignal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        [subscriber sendNext:@12];
        [subscriber sendNext:@15];
        [subscriber sendCompleted];
        return nil;
    }];
    
    
    //aggregateWithStart 运用 从哪个位置开始 进行顺序两值进行操作 最后只有一个被操作后的值
    [[operateSignal aggregateWithStart:@0 reduce:^id(NSNumber *running, NSNumber *next) {
        return @([running integerValue]+[next integerValue]);
    }] subscribeNext:^(id x) {
        NSLog(@"aggregateWithStart 当前值：%@",x);
    }];
    //输出
    //aggregateWithStart 当前值：29
    
    
    //scanWithStart  从哪个位置开始  然后每个位置跟前面的值进行操作 它会有根据NEXT的个数来显示对应的值
    [[operateSignal scanWithStart:@0 reduce:^id(NSNumber *running, NSNumber *next) {
        return @([running integerValue]+[next integerValue]);
    }] subscribeNext:^(id x) {
        NSLog(@"scanWithStart 当前值：%@",x);
    }];
    //输出
    //scanWithStart 当前值：2
    //scanWithStart 当前值：14
    //scanWithStart 当前值：29
}

//信号队列的使用 信号队列顾名思义就是将一组信号排成队列，挨个调用
-(void)createSignalGroup
{
    //创建3个信号来模拟队列
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"喜欢一个人"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"直接去表白"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalD = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"成功在一起"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //*****连接组队列:将几个信号放进一个组里面,按顺序连接每个,每个信号必须执行sendCompleted方法后才能执行下一个信号*******
    RACSignal *signalGroup = [[signalB concat:signalC] concat:signalD];
    [signalGroup subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //输出：喜欢一个人   直接去表白   成功在一起
    
    
    //信号合并队列:当其中信号方法执行完后便会执行下个信号
    [[RACSignal merge:@[signalB,signalC,signalD]] subscribeNext:^(id x) {
        NSLog(@"merge:%@",x);
    }];
    //输出：merge:喜欢一个人   merge:直接去表白   merge:成功在一起
    
    //说明：concat跟merge的区别：concat每个信号必须执行sendCompleted方法后才能执行下一个信号，而merge不用
    
    // 跟then的区别: then返回的信号只会订阅最后一个信号;
}


//信号的压缩
-(void)createSignalZip
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"我想你"];
        [subscriber sendNext:@"我不想你"];
        [subscriber sendNext:@"Test"];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"嗯"];
        [subscriber sendNext:@"你豁我"];
        return nil;
    }];
    //    压缩具有一一对应关系,以2个信号中 消息发送数量少的为主对应
    [[signalA zipWith:signalB] subscribeNext:^(RACTuple* x) {
        //解包RACTuple中的对象
        RACTupleUnpack(NSString *stringA, NSString *stringB) = x;
        NSLog(@"%@%@", stringA, stringB);
    }];
    //输出：我想你嗯   我不想你你豁我
    //说明：若将此结果于合并作对比，我们可以发现他们只是触发next事件的次数所关联对象不一样，是以信号中next事件数量较少的为主
}

@end
