//
//  AFFNRequest.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFFNCallbackObject.h"

typedef NS_ENUM(NSUInteger, AFFNPostType)
{
    kAFFNPost,
    kAFFNGet
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
    
    BOOL executing;
    BOOL finished;
    
    void (^_completion)(AFFNCallbackObject *result);
    void (^_failure)(NSError *error);
}

+ (AFFNRequest *)requestWithURL:(NSString *)urlString connectionType:(AFFNPostType)type andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailBlock:(void (^)(NSError *error))failure;

- (AFFNRequest *)initWithURL:(NSString *)urlString connectionType:(AFFNPostType)type andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailBlock:(void (^)(NSError *error))failure;

@property (readonly) float progress;                    //A float between 0.0 and 1.0
@property (nonatomic, assign) BOOL isConcurrent;        //Default is 'TRUE'
@property (nonatomic, readonly) BOOL isExecuting;
@property (nonatomic, readonly) BOOL isFinished;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSURLCacheStoragePolicy storagePolicy;

@end