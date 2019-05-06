//
//  AutoRefreshTool.m
//  AutoRefreshTool
//
//  Created by Rubick on 2018/1/8.
//  Copyright © 2018年 Accentrix. All rights reserved.
//

#import "AutoRefreshTool.h"
#import "TestAutoRefreshVC.h"
#import "ACCNetworkTool.h"
#import "AutoRefreshModel.h"
#import <SVProgressHUD/SVProgressHUD.h>
const NSString *PAGE_STR_FOR_SERVER = @"page"; // 修改未对应的服务器所要的参数
const NSString *PAGESIZE_STR_FOR_SERVER = @"pageSize"; // 修改未对应的服务器所要的参数

@interface AutoRefreshTool()

@property (strong, nonatomic) NSMutableDictionary *refreshModelDict;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) NSURLSessionTask *headerTask;
@property (weak, nonatomic) NSURLSessionTask *footerTask;
@property (weak, nonatomic) AutoRefreshModel *currRefreshModel;

@end

@implementation AutoRefreshTool

- (id)init {
    self = [super init];
    if(self){
        _refreshModelDict = [NSMutableDictionary dictionary];
        _defaultPageSize = 10;
    }
    return self;
}
#pragma mark  -- Register & init DataSource
- (void)registerScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    NSSet *identifierSet = [self.myDelegate autoRefreshIdentifiersForDataSource];
    NSArray *identifiers = identifierSet.allObjects;
    [identifiers enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AutoRefreshModel *refreshModel = [[AutoRefreshModel alloc] init];
        refreshModel.currPage = 0;
        refreshModel.hasNextPage = YES;
        refreshModel.pageSize = _defaultPageSize;
        refreshModel.dataSource = [NSMutableArray array];
        [self.refreshModelDict setValue:refreshModel forKeyPath:obj];
    }];
    _currDataIdentifier = identifiers[0]?identifiers[0]:nil;
    [scrollView setMj_header:[MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshAction)]];
    if(_defaultPageSize > 0){
        [scrollView setMj_footer:[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshAction)]];
    }
}
#pragma mark  --  数据源
/** 从DataSource字典中获取，目前的DataSourceModel */
- (AutoRefreshModel *)currRefreshModel {
    return [self.refreshModelDict objectForKey:self.currDataIdentifier];
}
- (void)setCurrRefreshModel:(AutoRefreshModel *)model {
    [self.refreshModelDict setObject:model forKey:self.currDataIdentifier];
}
#pragma make  --
- (void)cancelHeaderRefresh {
    [_headerTask cancel];
    if([_scrollView.mj_header isRefreshing]){
        [_scrollView.mj_header endRefreshing];
    }
}
- (void)cancelFooterRefresh {
    [_footerTask cancel];
    if([_scrollView.mj_footer isRefreshing]){
        [_scrollView.mj_footer endRefreshing];
    }
}
- (void)setRefreshStateWithHaveNextPage:(BOOL)have {
    if(have){
        [self.scrollView.mj_footer setState:MJRefreshStateIdle];
    } else {
        [self.scrollView.mj_footer setState:MJRefreshStateNoMoreData];
    }
}
- (void)allRequstsCancel {
    [_headerTask cancel];
    [_footerTask cancel];
}
#pragma mark  -- Header Refresh
- (void)headerRefreshAction {
    [self allRequstsCancel];
    if([_scrollView.mj_footer isRefreshing]){
        [_scrollView.mj_footer endRefreshing];
    }
    AutoRefreshModel *currModel = [self currRefreshModel];
    currModel.currPage = 0;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:_patameterDict];
    if(currModel.pageSize > 0){
        [dict setObject:[NSNumber numberWithInt:currModel.currPage] forKey:PAGE_STR_FOR_SERVER];
        [dict setObject:[NSNumber numberWithInt:currModel.pageSize] forKey:PAGESIZE_STR_FOR_SERVER];
    }
    currModel.hasNextPage = YES;
    [self setRefreshStateWithHaveNextPage:YES];
    __block AutoRefreshTool *weakSelf = self;
    self.headerTask = [ACCNetworkTool postWithURL:_apiURLs paramaters:dict success:^(id responseObject) {
        [weakSelf headerRefreshSuccessActionWithObject:responseObject];
        [weakSelf headerRefreshCompletedAction];
    } failure:^(NSError *error) {
        [weakSelf headerRefreshFailedActionWithError:error];
        [weakSelf headerRefreshCompletedAction];
    } progress:nil];
}
- (void)headerRefreshCompletedAction {
    if([self.myDelegate respondsToSelector:@selector(actionBeforeViewReloadData)]){
        [self.myDelegate actionBeforeViewReloadData];
    }
    if([_scrollView isKindOfClass:[UITableView class]]){
        [(UITableView *)_scrollView reloadData];
    } else if([_scrollView isKindOfClass:[UICollectionView class]]){
        [(UICollectionView *)_scrollView reloadData];
    }
    [[self.scrollView mj_header] endRefreshing];
}
- (void)headerRefreshSuccessActionWithObject:(id)object {
    AutoRefreshModel *currModel = [self currRefreshModel];
    [currModel.dataSource removeAllObjects];
    NSArray *dataArr = [self.myDelegate convertDataToModelArrayWithObject:object];
    if([dataArr count] < currModel.pageSize){
        currModel.hasNextPage = NO;
        [self setRefreshStateWithHaveNextPage:currModel.hasNextPage];
    }
    [currModel.dataSource addObjectsFromArray:dataArr];
    [self setCurrRefreshModel:currModel];
}
- (void)headerRefreshFailedActionWithError:(NSError *)error {
    if([self.myDelegate respondsToSelector:@selector(refreshFailedActionWithError:)]){
        [self.myDelegate refreshFailedActionWithError:error];
    } else {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}
#pragma mark  -- Footer Refresh
- (void)footerRefreshAction {
    AutoRefreshModel *currModel = [self currRefreshModel];
    if([_scrollView.mj_header isRefreshing] || currModel.pageSize <= 0){
        [_scrollView.mj_footer endRefreshing];
        return;
    }
    if(!currModel.hasNextPage){
        [_scrollView.mj_header setState:MJRefreshStateNoMoreData];
        return;
    }
    currModel.currPage = currModel.currPage + 1;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:_patameterDict];
    [dict setObject:[NSNumber numberWithInt:currModel.currPage] forKey:PAGE_STR_FOR_SERVER];
    [dict setObject:[NSNumber numberWithInt:currModel.pageSize] forKey:PAGESIZE_STR_FOR_SERVER];
    __block AutoRefreshTool *weakSelf = self;
    self.footerTask = [ACCNetworkTool postWithURL:_apiURLs paramaters:dict success:^(id responseObject) {
        [weakSelf footerRefreshSuccessActionWithObject:responseObject];
        [weakSelf footerRefreshCompletedAction];
    } failure:^(NSError *error) {
        [weakSelf footerRefreshFailedActionWithError:error];
        [weakSelf footerRefreshCompletedAction];
    } progress:nil];
    
}
- (void)footerRefreshCompletedAction {
    if([self.myDelegate respondsToSelector:@selector(actionBeforeViewReloadData)]){
        [self.myDelegate actionBeforeViewReloadData];
    }
    if([_scrollView isKindOfClass:[UITableView class]]){
        [(UITableView *)_scrollView reloadData];
    } else if([_scrollView isKindOfClass:[UICollectionView class]]){
        [(UICollectionView *)_scrollView reloadData];
    }
}
- (void)footerRefreshFailedActionWithError:(NSError *)error {
    AutoRefreshModel *currModel = [self currRefreshModel];
    if(currModel.currPage >= 1){
        currModel.currPage = currModel.currPage - 1;
    }
    [self setCurrRefreshModel:currModel];
    if([self.myDelegate respondsToSelector:@selector(refreshFailedActionWithError:)]){
        [self.myDelegate refreshFailedActionWithError:error];
    } else {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}
- (void)footerRefreshSuccessActionWithObject:(id)object {
    AutoRefreshModel *currModel = [self currRefreshModel];
    NSArray *dataArr = [self.myDelegate convertDataToModelArrayWithObject:object];
    if([dataArr count] < currModel.pageSize){
        currModel.hasNextPage = NO;
    } else {
        currModel.hasNextPage = YES;
    }
    [self setRefreshStateWithHaveNextPage:currModel.hasNextPage];
    [currModel.dataSource addObjectsFromArray:dataArr];
    [self setCurrRefreshModel:currModel];
}

@end
