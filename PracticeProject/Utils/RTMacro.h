//
//  RTMacro.h
//  PracticeProject
//
//  Created by lynn on 2017/8/2.
//  Copyright © 2017年 lynn. All rights reserved.
//

#ifndef RTMacro_h
#define RTMacro_h

///------
/// Log
///------

#ifdef DEBUG

#define LRLog(...)      NSLog(@"%s 第%d行 >>>>>>>>>>>>>>>>>>>> : %@\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__]);

#define RTLogError(error) NSLog(@"Error: %@", error)

#else

#define NSLog(...)
#define RTLog(...)
#define RTLogError(error)

#endif


///------
/// App
///------
#define kApplication        [UIApplication sharedApplication]
#define kAppWindow          [UIApplication sharedApplication].delegate.window
#define kAppDelegate        [AppDelegate shareAppDelegate]
#define kRootViewController [UIApplication sharedApplication].delegate.window.rootViewController
#define kUserDefaults       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter [NSNotificationCenter defaultCenter]

///------
/// Assert
///------
#define RTAssertNil(condition, description, ...) NSAssert(!(condition), (description), ##__VA_ARGS__)
#define RTCAssertNil(condition, description, ...) NSCAssert(!(condition), (description), ##__VA_ARGS__)

#define RTAssertNotNil(condition, description, ...) NSAssert((condition), (description), ##__VA_ARGS__)
#define RTCAssertNotNil(condition, description, ...) NSCAssert((condition), (description), ##__VA_ARGS__)

#define RTAssertMainThread() NSAssert([NSThread isMainThread], @"This method must be called on the main thread")
#define RTCAssertMainThread() NSCAssert([NSThread isMainThread], @"This method must be called on the main thread")

///------
/// 设备信息
///------
#define isAppFirstStarted()   [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppFirstStart"]intValue] == 0?YES:NO
#define setAppStarted()       [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"AppFirstStart"];[[NSUserDefaults standardUserDefaults] synchronize];

#define RT_IOSVersion     [[UIDevice currentDevice] systemVersion]
#define RT_AboveIOS7      ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define RT_AboveIOS8      ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define RT_AboveIOS9      ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

#define RT_isIPhone4      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define RT_isIPhone5      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define RT_isIPhone6      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define RT_isIPhone6Plus  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define RT_isIPad         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define RT_isIPhone       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define RT_Version        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define RT_BundleVersion   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define RT_AppName        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define RT_ProjectName    [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey]

#define RT_ScreenWidth    [UIScreen mainScreen].bounds.size.width
#define RT_ScreenHeight   [UIScreen mainScreen].bounds.size.height
#define RT_ScreenBounds    [UIScreen mainScreen].bounds

#define RT_Language       [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0]
#define RT_Hans           [kLanguage hasPrefix:@"zh-Hans"]
#define RT_Hant           ([kLanguage rangeOfString:@"^(zh-Hant|zh-HK|zh-TW).*$" options:NSRegularExpressionSearch].location != NSNotFound)
#define RT_HansOrHant     (kHans || kHant)

///------
/// 沙盒目录
///------
#define RT_PathOfDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define RT_PathOfCaches   [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define RT_PathOfTmp      NSTemporaryDirectory()
#define RT_PathOfHome     NSHomeDirectory()

#define RT_URLOfDocument  [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]

///------
/// 通知中心
///------
#define RTNotificationCenter [NSNotificationCenter defaultCenter]

///------
/// 颜色
///------
#define RTRGBColor(r, g, b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define RTRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(r)/255.0 blue:(r)/255.0 alpha:a]

#define HEXCOLOR(string)                [UIColor colorWithHexString:string]
#define HEXCOLOR_ALPHA(string,alpha)    [UIColor colorWithHexString:string Alpha:alpha]

#define RTRandomColor           [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]
#define RTClearColor            [UIColor clearColor]

#define Global_mainBackgroundColor  RGB(248, 248, 248)

///------
/// APP风格
///------
#define BarTintColor        [UIColor colorWithHexString:@"#f6f5f5"]
#define TintColor           [UIColor colorWithHexString:@"007AFF"]
#define NavTitleColor       [UIColor blackColor]
#define TabBarTitleColor    [UIColor colorWithHexString:@"#ED4C38"]
#define ButtonColor         [UIColor colorWithHexString:@"#E64340"]
#define TextColor           [UIColor colorWithHexString:@"#555555"]

#define RTFont(size)        [UIFont systemFontOfSize:size]
#define RTBoldFont(size)    [UIFont boldSystemFontOfSize:size]

#define RT_Font_H1          RTBoldFont(19)
#define RT_Font_H2          RTFont(17)
#define RT_Font_H3          RTFont(15)
#define RT_Font_H4          RTFont(12)

///------
/// 弱/强引用
///------
#define RTWeakSelf(type)    __weak typeof(type) weak##type = type;
#define RTStrongSelf(type)  __strong typeof(type) type = weak##type;

///------
/// view 圆角和边框
///------
#define RTViewWithBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

///------
/// 图片
///------
#define RTImageNamed(_name) [UIImage imageNamed:_name]]


#endif /* RTMacro_h */
