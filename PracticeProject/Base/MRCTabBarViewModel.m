//
//  MRCTabBarViewModel.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 15/1/9.
//  Copyright (c) 2015年 leichunfeng. All rights reserved.
//

#import "MRCTabBarViewModel.h"

@interface MRCTabBarViewModel ()


@property (nonatomic, strong, readwrite) RTUIComponentViewModel *uiComponentViewModel;

@property (nonatomic, strong, readwrite) RTNoteViewModel *noteViewModel;

@property (nonatomic, strong, readwrite) RTMagicViewModel *magicViewModel;

@property (nonatomic, strong, readwrite) RTExpandViewModel *expandViewModel;

@end

@implementation MRCTabBarViewModel

- (void)initialize
{
    [super initialize];
    
    _uiComponentViewModel = [[RTUIComponentViewModel alloc] init];
    _noteViewModel = [[RTNoteViewModel alloc] init];
    _magicViewModel = [[RTMagicViewModel alloc] init];
    _expandViewModel = [[RTExpandViewModel alloc] init];
    
}

@end
