//
//  AFFNRequest.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    POST,
    GET
} postType;

@protocol AFFNRequestDelegate <NSObject>

@property()void (^_completion)(NSDictionary *result);
@property()void (^_failure)(NSError *error);

@end

@interface AFFNRequest : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    @private
    NSDictionary *_params;
    NSString *_urlString;
    postType _type;
    NSURLConnection *_connection;
    
    NSURL *finalURL;
    NSMutableURLRequest *request;
    
    NSMutableData *receivedData;
    NSDate *requestTime;
    
    BOOL executing;
    BOOL finished;
}

- (AFFNRequest *)initWithURL:(NSString *)urlString connectionType:(postType)type andParams:(NSDictionary *)params withCompletion:(void (^)(NSDictionary *result))completion andFailBlock:(void (^)(NSError *error))failure andSender:(id<AFFNRequestDelegate>)delegate;

@property(readonly)float progress;
@property(readwrite, retain)id<AFFNRequestDelegate> delegate;

@end