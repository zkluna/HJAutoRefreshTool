//
//  AutoRefreshTool.h
//  AutoRefreshTool
//
//  Created by Rubick on 2018/1/8.
//  Copyright © 2018年 Accentrix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoRefreshModel.h"
#import <MJRefresh/MJRefresh.h>
#import <AFNetworking/AFNetworking.h>
@class TestAutoRefreshVC;

@protocol AutoRefreshToolDelegate<NSObject>

@required
/** DataSource identifiers */
- (NSSet<NSString *>*)autoRefreshIdentifiersForDataSource;
/** 将获取的数据转换成model数组 */
- (NSArray *)convertDataToModelArrayWithObject:(id)object;
@optional
/** 视图将要刷新此时DataSource已经是新数据 */
- (void)actionBeforeViewReloadData;
/** 数据加载错误处理方法 */
- (void)refreshFailedActionWithError:(NSError *)error;
///** custom header refresh action */
//- (void)autoRefreshHeaderRefreshAction;
//- (void)autoRefreshHeaderRefreshCompletedAction;
//- (void)autoRefreshHuccessWithObject:(id)object;
//- (void)autoRefreshHeaderRefreshFailWithError:(NSError *)error;
//
///** custom footer refresh action */
//- (void)autoRefreshFooterRefreshAction;
//- (void)autoRefreshFooterRefreshCompletedAction;
//- (void)autoRefreshFooterRefreshSuccessWithObject:(id)object;
//- (void)autoRefreshFooterRefreshFFailWithError:(NSError *)error;

@end

@interface AutoRefreshTool : NSObject

@property (weak, nonatomic) id<AutoRefreshToolDelegate> myDelegate;
@property (readonly, weak, nonatomic) UIScrollView *scrollView;

@property (copy, nonatomic) NSString *apiURLs;
@property (strong, nonatomic) NSMutableDictionary *patameterDict;

@property (unsafe_unretained, nonatomic) int defaultPageSize;
@property (readonly, weak, nonatomic) NSURLSessionTask *headerTask;
@property (readonly, weak, nonatomic) NSURLSessionTask *footerTask;

/** 切换DataSource的时候需要修改对应的标识符 */
@property (copy, nonatomic) NSString *currDataIdentifier;

/** 当前刷新的model */
@property (strong, nonatomic, readonly) AutoRefreshModel *currRefreshModel;

- (void)registerScrollView:(UIScrollView *)scrollView;

- (void)cancelHeaderRefresh;
- (void)cancelFooterRefresh;

@end
