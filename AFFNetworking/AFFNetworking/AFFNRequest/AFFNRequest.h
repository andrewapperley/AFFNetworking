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
    NSString *_urlString;
    AFFNPostType _type;
    NSURLConnection *_connection;
    
    NSURL *finalURL;
    NSMutableURLRequest *request;
    
    NSMutableData *receivedData;
    NSDate *requestTime;
    
    BOOL _upDone;
    BOOL _downDone;
    
    //Downloading progress
    CGFloat expectedDataLength;
    CGFloat downloadDataLength;
    
    //Blocks
    void (^_completionBlock)(AFFNCallbackObject *result);
    void (^_failureBlock)(NSError *error);
    void (^_upProgressBlock)(CGFloat upProgress);
    void (^_downProgressBlock)(CGFloat downProgress);
}

+ (AFFNRequest *)requestWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure;
+ (AFFNRequest *)requestWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure andUploadProgressBlock:(void (^)(CGFloat uploadProgress))uploadProgressBlock andDownloadProgressBlock:(void (^)(CGFloat downloadProgress))downloadProgressBlock;

- (AFFNRequest *)initWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure;
- (AFFNRequest *)initWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure andUploadProgressBlock:(void (^)(CGFloat uploadProgress))uploadProgressBlock andDownloadProgressBlock:(void (^)(CGFloat downloadProgress))downloadProgressBlock;

@property (nonatomic, retain) NSArray *multipartData;
@property (nonatomic, assign) NSString *multiSeparator; //This is used for separating multi request data
@property (nonatomic, assign) BOOL isConcurrent;        //Default is 'TRUE'
@property (nonatomic, readonly) BOOL isExecuting;
@property (nonatomic, readonly) BOOL isFinished;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSURLCacheStoragePolicy storagePolicy;

@end