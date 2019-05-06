//
//  BaseAutoRefreshVC.m
//  AutoRefreshTool
//
//  Created by Rubick on 2018/1/8.
//  Copyright © 2018年 Accentrix. All rights reserved.
//

#import "TestAutoRefreshVC.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface TestAutoRefreshVC ()<AutoRefreshToolDelegate>

@end

@implementation TestAutoRefreshVC

- (instancetype)init {
    self = [super init];
    if(self){
        [self initPageTool];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initPageTool];
    }
    return self;
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        [self initPageTool];
    }
    return self;
}
- (void)initPageTool {
    _pageTool = [[AutoRefreshTool alloc] init];
    _pageTool.myDelegate = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(_tableView){
        [_pageTool registerScrollView:_tableView];
    }
    if(_collectionView){
        [_pageTool registerScrollView:_collectionView];
    }
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
