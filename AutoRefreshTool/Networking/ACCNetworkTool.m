//
//  NetworkTool.m
//  DeapLearn
//
//  Created by Rubick on 2017/11/3.
//  Copyright © 2017年 ***. All rights reserved.
//

#import "ACCNetworkTool.h"

static AFHTTPSessionManager *_sessionManager;
static NSMutableArray *_allSeesionTask;

@implementation ACCNetworkTool

+ (void)initialize {
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer.timeoutInterval = 60.f;
    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/json",@"text/plain",@"text/javascript",@"text/xml",@"image/*", nil];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}
+ (NSMutableArray *)allSessionTask {
    if(!_allSeesionTask){
        _allSeesionTask = [[NSMutableArray alloc] init];
    }
    return _allSeesionTask;
}
+ (void)cancelAllRequest {
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}
+ (void)cancelRequestWithURL:(NSString *)url {
    if(!url) return;
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if([task.currentRequest.URL.absoluteString hasPrefix:url]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}
+ (NSURLSessionTask *)getWithURL:(NSString *)URL paramaters:(NSDictionary *)parameters success:(NetworkResponseSuccess)success failure:(NetworkResponseFailure)failure progress:(NetworkingProgress)progress {
    NSURLSessionTask *sessionTask = [_sessionManager GET:URL parameters:parameters progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        success?success(responseObject):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure?failure(error):nil;
    }];
    sessionTask?[[self allSessionTask] addObject:sessionTask]:nil;
    return sessionTask;
}
+ (NSURLSessionTask *)postWithURL:(NSString *)URL paramaters:(NSDictionary *)parameters success:(NetworkResponseSuccess)success failure:(NetworkResponseFailure)failure progress:(NetworkingProgress)progress {
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        success?success(responseObject):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure?failure(error):nil;
    }];
    sessionTask?[[self allSessionTask] addObject:sessionTask]:nil;
    return sessionTask;
}
+ (NSURLSessionTask *)uploadWithURL:(NSString *)URL parameters:(NSDictionary *)parameters images:(NSArray<UIImage *> *)images name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType progress:(NetworkingProgress)progress success:(NetworkResponseSuccess)success failure:(NetworkResponseFailure)failure {
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *imageData = UIImageJPEGRepresentation(obj, 0.5);
            [formData appendPartWithFileData:imageData name:name fileName:[NSString stringWithFormat:@"%@%lu.%@",fileName,idx,mimeType ? mimeType : @"jpeg"] mimeType:[NSString stringWithFormat:@"image/%@",mimeType ? mimeType : @"jpeg"]];
        }];
    } progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        success?success(responseObject):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure?failure(error):nil;
    }];
    sessionTask?[[self allSessionTask] addObject:sessionTask]:nil;
    return sessionTask;
}
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL fileDir:(NSString *)fileDir progress:(NetworkingProgress)progress success:(void (^)(NSString *))success failure:(NetworkResponseFailure)failure {
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:requst progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir?fileDir:@"Download"];
        NSFileManager *fileMananger = [NSFileManager defaultManager];
        [fileMananger createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allSessionTask] removeObject:downloadTask];
        if(failure && error){
            failure(error);
            return;
        } else {
            success?success(filePath.absoluteString):nil;
        }
    }];
    [downloadTask resume];
    downloadTask?[[self allSessionTask] addObject:downloadTask]:nil;
    return downloadTask;
}

@end
