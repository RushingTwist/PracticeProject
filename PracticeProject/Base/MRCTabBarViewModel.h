//
//  MRCTabBarViewModel.h
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 15/1/9.
//  Copyright (c) 2015年 leichunfeng. All rights reserved.
//

#import "MRCViewModel.h"

#import "RTExpandViewModel.h"
#import "RTMagicViewModel.h"
#import "RTNoteViewModel.h"
#import "RTUIComponentViewModel.h"

@interface MRCTabBarViewModel : MRCViewModel


@property (nonatomic, strong, readonly) RTUIComponentViewModel *uiComponentViewModel;

@property (nonatomic, strong, readonly) RTNoteViewModel *noteViewModel;

@property (nonatomic, strong, readonly) RTMagicViewModel *magicViewModel;

@property (nonatomic, strong, readonly) RTExpandViewModel *expandViewModel;

@end
