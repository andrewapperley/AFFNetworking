//
//  AFFNRequest.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AFFNPostType)
{
    kAFFNPost,
    kAFFNGet
};

@protocol AFFNRequestDelegate <NSObject>

@property (assign) void (^_completion)(NSDictionary *result);
@property (assign) void (^_failure)(NSError *error);

@end

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
}

- (AFFNRequest *)initWithURL:(NSString *)urlString connectionType:(AFFNPostType)type andParams:(NSDictionary *)params withCompletion:(void (^)(NSDictionary *result))completion andFailBlock:(void (^)(NSError *error))failure andDelegate:(id<AFFNRequestDelegate>)delegate;

@property(readonly)float progress;
@property(readwrite, assign)id<AFFNRequestDelegate> delegate;

@end