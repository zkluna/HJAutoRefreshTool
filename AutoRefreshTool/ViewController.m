//
//  ViewController.m
//  AutoRefreshTool
//
//  Created by rubick on 2018/1/8.
//  Copyright © 2018年 Accentrix. All rights reserved.
//

#import "ViewController.h"
#import "TestListVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"xxx" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTest)];
    self.navigationItem.rightBarButtonItem = right;
}
- (void)cancelTest {

}
- (IBAction)pushAction:(UIButton *)sender {
    TestListVC *listVC = [[TestListVC alloc] init];
    [self.navigationController pushViewController:listVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
