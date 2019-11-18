//
//  ViewController.m
//  Laboratory
//
//  Created by wangfulin-yfzx on 2019/11/18.
//  Copyright © 2019 zzz-yfzx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSString *cls = @"FileManagerViewController";
    
    UIStoryboard *main=[UIStoryboard storyboardWithName:cls bundle:nil];
    UIViewController *vc = [main instantiateViewControllerWithIdentifier:cls];
   
    if (!vc) {
        vc = [[NSClassFromString(cls) class] new];
    }
    [self.navigationController pushViewController:vc animated:YES];
}
@end
