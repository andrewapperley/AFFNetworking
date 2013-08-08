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

@interface AFFNRequest : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    @private
    NSDictionary *_params;
    NSString *_urlString;
    postType _type;
}

- (AFFNRequest *)initWithURL:(NSString *)urlString connectionType:(postType)type andParams:(NSDictionary *)params withCompletion:(void (^)(NSDictionary *result))completion andFailBlock:(void (^)(NSError *error))failure;

@end
