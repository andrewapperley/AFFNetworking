//
//  AFFNRequest.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum {
    POST,
    GET
} postType;

@interface AFFNRequest : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    @private
    NSDictionary *_params;
    NSString *_urlString;
    postType _type;
    NSURLConnection *_connection;
    
    NSURL *finalURL;
    NSURLRequest *request;
    
    void (^_completion)(NSDictionary *result);
    void (^_failure)(NSError *error);
    NSMutableData *receivedData;
    NSDate *requestTime;
}

- (AFFNRequest *)initWithURL:(NSString *)urlString connectionType:(postType)type andParams:(NSDictionary *)params withCompletion:(void (^)(NSDictionary *result))completion andFailBlock:(void (^)(NSError *error))failure;

@end