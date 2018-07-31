//
//  TestViewController.m
//  PracticeProject
//
//  Created by 王福林 on 2018/5/2.
//  Copyright © 2018年 lynn. All rights reserved.
//

#import "TestViewController.h"
#import "PubKeyHelper.h"

@interface TestViewController ()

@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"testtttt";
    self.view.backgroundColor = [UIColor blackColor];
    
    
    
}


#pragma mark - UITableViweDelegate,UITableViweDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    NSString *title = self.dataSource[indexPath.row];
    cell.textLabel.text = title;
    cell.textLabel.textColor = [UIColor redColor];
    cell.contentView.backgroundColor = [UIColor blackColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *className = self.dataSource[indexPath.row];
    UIViewController *vc = [NSClassFromString(className) new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getter
- (NSArray *)dataSource
{
    if (!_dataSource) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Test List" ofType:@"plist"];
        _dataSource = [[NSArray alloc] initWithContentsOfFile:path];
    }
    return _dataSource;
}

@end
