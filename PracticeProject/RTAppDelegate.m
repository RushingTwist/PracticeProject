//
//  RTAppDelegate.m
//  PracticeProject
//
//  Created by lynn on 2015/7/25.
//  Copyright © 2015年 lynn. All rights reserved.
//

#import "RTAppDelegate.h"


@interface RTAppDelegate ()



@end

@implementation RTAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self configureFMDB];
    [self configureAppearance];
    [self configureKeyboardManager];
    [self configureReachability];

    self.window = [UIWindow new];
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor redColor];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    [self configureAppearance];
    
    return YES;
}


#pragma mark - Application configuration

- (void)configureFMDB {
    
}

- (void)configureAppearance {
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 0x2F434F
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:(48 - 40) / 215.0 green:(67 - 40) / 215.0 blue:(78 - 40) / 215.0 alpha:1];
    [UINavigationBar appearance].barStyle  = UIBarStyleBlack;
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    [UISegmentedControl appearance].tintColor = [UIColor whiteColor];
    
//    [UITabBar appearance].tintColor = HexRGB(colorI3);
}

- (void)configureKeyboardManager {
    IQKeyboardManager.sharedManager.enableAutoToolbar = NO;
    IQKeyboardManager.sharedManager.shouldResignOnTouchOutside = YES;
}

- (void)configureReachability {

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
