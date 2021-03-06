//
//  NetworkTool.h
//  DeapLearn
//
//  Created by Rubick on 2017/11/3.
//  Copyright © 2017年 ***. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>

/** 网络状态 */
typedef NS_ENUM(NSUInteger, NetworkingStatus) {
    NetworkingStatusUnknown,
    NetworkingStatusNotReachable,
    NetworkingStatusReachableViaWWAN,
    NetworkingStatusReachableViaWifi,
};
/** Request serializer type */
typedef NS_ENUM(NSUInteger, RequestSerializer) {
    RequestSerializerHTTP = 0,
    RequestSerializerJSON ,
};
/** Response serializer type */
typedef NS_ENUM(NSUInteger, ResponseSerializer) {
    ResponseSerializerHTTP,
    ResponseSerializerJSON,
    ResponseSerializerXML,
};
/** 成功回调 */
typedef void(^NetworkResponseSuccess)(id responseObject);
/** 失败回调 */
typedef void(^NetworkResponseFailure)(NSError *error);
/** 进度block */
typedef void(^NetworkingProgress)(NSProgress *progress);
/** 网络状态block */
typedef void(^NetworkingStatusBlock)(NetworkingStatus status);

@interface ACCNetworkTool : NSObject

/** 网络请求头设置 */
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/** 取消请求 */
+ (void)cancelAllRequest;
+ (void)cancelRequestWithURL:(NSString *)url;

/** get请求 */
+ (NSURLSessionTask *)getWithURL:(NSString *)URL paramaters:(NSDictionary *)parameters success:(NetworkResponseSuccess)success failure:(NetworkResponseFailure)failure progress:(NetworkingProgress)progress;
/** post请求 */
+ (NSURLSessionTask *)postWithURL:(NSString *)URL paramaters:(NSDictionary *)parameters success:(NetworkResponseSuccess)success failure:(NetworkResponseFailure)failure progress:(NetworkingProgress)progress;

/** 上传图片 */
+ (NSURLSessionTask *)uploadWithURL:(NSString *)URL parameters:(NSDictionary *)parameters images:(NSArray<UIImage *>*)images name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType progress:(NetworkingProgress)progress success:(NetworkResponseSuccess)success failure:(NetworkResponseFailure)failure;
/** 下载 */
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL fileDir:(NSString *)fileDir progress:(NetworkingProgress)progress success:(void(^)(NSString *filePath))success failure:(NetworkResponseFailure)failure;

@end
