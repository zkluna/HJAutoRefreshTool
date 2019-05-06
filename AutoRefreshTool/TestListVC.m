//
//  TestListVC.m
//  AutoRefreshTool
//
//  Created by rubick on 2018/1/10.
//  Copyright © 2018年 Accentrix. All rights reserved.
//

#import "TestListVC.h"
#import "AutoRefreshTool.h"
#import "AutoRefreshModel.h"
#import <MJRefresh/MJRefresh.h>
#import "TestModel.h"

const NSString *localTestURL = @"http://127.0.0.1:5000/numList"; // 请换成你要测试的接口（注意分页的参数如果不一样请修改refreshTool里的设置）。懒得去抓别人的接口来测试，就自己用python写了个本地测试

@interface TestListVC ()<UITableViewDelegate, UITableViewDataSource, AutoRefreshToolDelegate>

@end

@implementation TestListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"test";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.pageTool setApiURLs:localTestURL];
    [self.tableView.mj_header beginRefreshing];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pageTool.currRefreshModel.dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableView class])];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    TestModel *model = self.pageTool.currRefreshModel.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"第%@个",[model.line stringValue]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"第%@页",[model.page stringValue]];
    return cell;
}
- (NSSet<NSString *> *)autoRefreshIdentifiersForDataSource {
    return [NSSet setWithArray:@[@"UITableView"]];
}
- (NSArray *)convertDataToModelArrayWithObject:(id)object {
    NSLog(@"%@",object);
    return [TestModel mj_objectArrayWithKeyValuesArray:object];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
