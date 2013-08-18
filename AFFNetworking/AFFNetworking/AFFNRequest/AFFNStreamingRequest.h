//
//  AFFNStreamingRequest.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-17.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNRequest.h"

@interface AFFNStreamingRequest : AFFNRequest
{
    @private
    NSString *fileName;
    NSString *extType;
    NSFileHandle *streamingFile;
    NSString *filePath;
}

+ (AFFNStreamingRequest *)streamingRequestWithFileName:(NSString *)name andExtention:(NSString *)ext andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure;

@end