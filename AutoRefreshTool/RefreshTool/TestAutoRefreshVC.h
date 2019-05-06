//
//  BaseAutoRefreshVC.h
//  AutoRefreshTool
//
//  Created by Rubick on 2018/1/8.
//  Copyright © 2018年 Accentrix. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AutoRefreshTool.h"
#import "AutoRefreshModel.h"

@interface TestAutoRefreshVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) AutoRefreshTool *pageTool;

@end
