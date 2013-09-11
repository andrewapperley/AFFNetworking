//
//  AFFNRequest.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//



#import <UIKit/UIKit.h>
#import "AFFNCallbackObject.h"

typedef NS_ENUM(NSUInteger, AFFNPostType)
{
    kAFFNPost,
    kAFFNGet,
    kAFFNMulti
};

/*
 * Init function to create the reqest object. It takes the URL in NSString format, POST/GET type, params to be used
 * in the request in NSDictionary format, and a completion/fail block for a callback.
 * //Without progress blocks
 * @params
 * AFFNPostType type
 * NSString urlString
 * NSDictionary params
 * void Block (AFFNCallbackObject) completion
 * void Block (NSError) failure
 *
 * //With progress blocks
 * @params
 * NSString name
 * NSString ext
 * NSString urlString
 * NSDictionary params
 * void Block (AFFNCallbackObject) completion
 * void Block (NSError) failure
 * void Block (float) uploadProgressBlock
 * void Block (float) downloadProgressBlock
 *
 * //Multi-Part POST
 * @params
 * NSString name
 * NSString ext
 * NSString urlString
 * NSDictionary params
 * void Block (AFFNCallbackObject) completion
 * void Block (NSError) failure
 * void Block (float) uploadProgressBlock
 * void Block (float) downloadProgressBlock
 * NSArray multiData
 */

#pragma mark - Constants
static const NSTimeInterval __AFFNDefaultTimeout = 120;
static const NSURLCacheStoragePolicy __AFFNDefaultStoragePolicy = NSURLCacheStorageAllowedInMemoryOnly;
static const NSString *__AFFNDefaultMultiSeparator __attribute__((unused)) = @"---------------------_AFFNBoundary_";

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

+ (AFFNRequest *)requestWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *))completion andFailure:(void (^)(NSError *))failure andUploadProgressBlock:(void (^)(CGFloat))uploadProgressBlock andDownloadProgressBlock:(void (^)(CGFloat))downloadProgressBlock andMultiData:(NSArray *)multiData;

- (AFFNRequest *)initWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure;

@property (nonatomic, assign) NSString *multiSeparator; //This is used for separating multi request data
@property (nonatomic, assign) BOOL isConcurrent;        //Default is 'TRUE'
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSURLCacheStoragePolicy storagePolicy;

@end