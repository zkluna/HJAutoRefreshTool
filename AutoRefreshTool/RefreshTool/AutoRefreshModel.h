//
//  AutoRefreshModel.h
//  AutoRefreshTool
//
//  Created by Rubick on 2018/1/8.
//  Copyright © 2018年 Accentrix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoRefreshModel : NSObject

@property (unsafe_unretained, nonatomic) int currPage;
@property (unsafe_unretained, nonatomic) int pageSize;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (unsafe_unretained, nonatomic) BOOL hasNextPage;

@end
