//
//  AFFNRequest.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFFNCallbackObject.h"

typedef NS_ENUM(NSUInteger, AFFNPostType)
{
    kAFFNPost,
    kAFFNGet,
    kAFFNMulti
};



@interface AFFNRequest : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    @private
    NSDictionary *_params;
    NSArray *_multipartData;
    NSString *_urlString;
    AFFNPostType _type;
    
    NSURL *finalURL;
    NSMutableURLRequest *request;
    
    BOOL _upDone;
    BOOL _downDone;
    
    //Downloading progress
    CGFloat expectedDataLength;
    CGFloat downloadDataLength;
    
    @protected
    NSMutableData *receivedData;
    NSURLConnection *_connection;
    NSDate *requestTime;
    
    //Blocks
    void (^_completionBlock)(AFFNCallbackObject *result);
    void (^_failureBlock)(NSError *error);
    void (^_upProgressBlock)(CGFloat upProgress);
    void (^_downProgressBlock)(CGFloat downProgress);
}

+ (AFFNRequest *)requestWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure;
+ (AFFNRequest *)requestWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure andUploadProgressBlock:(void (^)(CGFloat uploadProgress))uploadProgressBlock andDownloadProgressBlock:(void (^)(CGFloat downloadProgress))downloadProgressBlock;
+ (AFFNRequest *)requestWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *))completion andFailure:(void (^)(NSError *))failure andUploadProgressBlock:(void (^)(CGFloat))uploadProgressBlock andDownloadProgressBlock:(void (^)(float))downloadProgressBlock andMultiData:(NSArray *)multiData;

- (AFFNRequest *)initWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure;

@property (nonatomic, assign) NSString *multiSeparator; //This is used for separating multi request data
@property (nonatomic, assign) BOOL isConcurrent;        //Default is 'TRUE'
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSURLCacheStoragePolicy storagePolicy;

@end