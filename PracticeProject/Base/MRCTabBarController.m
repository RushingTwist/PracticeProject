//
//  MRCTabBarController.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 15/1/9.
//  Copyright (c) 2015年 leichunfeng. All rights reserved.
//

#import "MRCTabBarController.h"
#import "MRCTabBarViewModel.h"

#import "MRCNavigationController.h"

#import "RTUIComponentViewController.h"
#import "RTNoteViewController.h"
#import "RTMagicViewController.h"
#import "RTExpandViewController.h"

@interface MRCTabBarController ()

@property (nonatomic, strong) MRCTabBarViewModel *viewModel;

@property (nonatomic, strong, readwrite) UITabBarController *tabBarController;

@end

@implementation MRCTabBarController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tabBarController = [[UITabBarController alloc] init];

    [self addChildViewController:self.tabBarController];
    [self.view addSubview:self.tabBarController.view];
    
    [self addAllChildVC];
}

- (void)addAllChildVC
{
    UINavigationController *uiComponentNavigationController = ({
        RTUIComponentViewController *uiComponentViewController = [[RTUIComponentViewController alloc] initWithViewModel:self.viewModel.uiComponentViewModel];
        
        UIImage *newsImage = [UIImage imageNamed:@"ui"];
        UIImage *newsHLImage = [[UIImage imageNamed:@"ui_highlight"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        uiComponentViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"UI" image:newsImage selectedImage:newsHLImage];
        
        [[MRCNavigationController alloc] initWithRootViewController:uiComponentViewController];
    });
    
    UINavigationController *noteNavigationController = ({
        RTNoteViewController *noteViewController = [[RTNoteViewController alloc] initWithViewModel:self.viewModel.noteViewModel];
        
        UIImage *newsImage = [UIImage imageNamed:@"note"];
        UIImage *newsHLImage = [[UIImage imageNamed:@"note_highlight"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        noteViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Note" image:newsImage selectedImage:newsHLImage];
        
        [[MRCNavigationController alloc] initWithRootViewController:noteViewController];
    });
    
    UINavigationController *magicNavigationController = ({
        RTMagicViewController *magicViewController = [[RTMagicViewController alloc] initWithViewModel:self.viewModel.magicViewModel];
        
        UIImage *newsImage = [UIImage imageNamed:@"magic"];
        UIImage *newsHLImage = [[UIImage imageNamed:@"magic_highlight"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        magicViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Magic" image:newsImage selectedImage:newsHLImage];
        
        [[MRCNavigationController alloc] initWithRootViewController:magicViewController];
    });
    
    UINavigationController *expandNavigationController = ({
        RTExpandViewController *expandViewController = [[RTExpandViewController alloc] initWithViewModel:self.viewModel.expandViewModel];
        
        UIImage *newsImage = [UIImage imageNamed:@"expand"];
        UIImage *newsHLImage = [[UIImage imageNamed:@"expand_highlight"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        expandViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Expand" image:newsImage selectedImage:newsHLImage];
        
        [[MRCNavigationController alloc] initWithRootViewController:expandViewController];
    });
    
    self.tabBarController.viewControllers = @[ uiComponentNavigationController, noteNavigationController, magicNavigationController, expandNavigationController ];
    
    [MRCSharedAppDelegate.navigationControllerStack pushNavigationController:uiComponentNavigationController];
    
    [[self
      rac_signalForSelector:@selector(tabBarController:didSelectViewController:)
      fromProtocol:@protocol(UITabBarControllerDelegate)]
     subscribeNext:^(RACTuple *tuple) {
         [MRCSharedAppDelegate.navigationControllerStack popNavigationController];
         [MRCSharedAppDelegate.navigationControllerStack pushNavigationController:tuple.second];
     }];
    self.tabBarController.delegate = self;
}

#pragma mark -
- (BOOL)shouldAutorotate {
    return self.tabBarController.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.tabBarController.selectedViewController.supportedInterfaceOrientations;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.tabBarController.selectedViewController.preferredStatusBarStyle;
}

@end
