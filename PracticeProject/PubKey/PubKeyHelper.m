//
//  PubKeyHelper.m
//  PracticeProject
//
//  Created by 王福林 on 2018/5/22.
//  Copyright © 2018年 lynn. All rights reserved.
//

#import "PubKeyHelper.h"

@implementation PubKeyHelper

+ (NSString *)loadPubKey
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"a" ofType:@"puk"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSString *pubKey = [data hexString];
    return pubKey;
}
@end
