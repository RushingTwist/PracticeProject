//
//  JsPatchViewController.m
//  PracticeProject
//
//  Created by 王福林 on 2018/5/2.
//  Copyright © 2018年 lynn. All rights reserved.
//

#import "JsPatchViewController.h"
#import "JSPatch/JPEngine.h"

@interface JsPatchViewController ()

@end

@implementation JsPatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test_jspatch];
}

- (void)test_jspatch
{
    [JPEngine startEngine];
    
    // 直接执行js
    [JPEngine evaluateScript:@"\
     var alertView = require('UIAlertView').alloc().init();\
     alertView.setTitle('Alert');\
     alertView.setMessage('AlertView from js'); \
     alertView.addButtonWithTitle('OK');\
     alertView.show(); \
     "];
    
//    // 从网络拉回js脚本执行
//    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://cnbang.net/test.js"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        [JPEngine evaluateScript:script];
//    }];
//    
//    // 执行本地js文件
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    [JPEngine evaluateScript:script];
}

@end
